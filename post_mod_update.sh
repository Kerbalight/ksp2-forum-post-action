#!/bin/bash

# Dependencies: curl, jq, pandoc, pup

# Input validation
forum_topic_url=$INPUT_FORUM_TOPIC_URL
changelog_file=$INPUT_CHANGELOG

forum_topic_id=$(echo "$forum_topic_url" | sed -E 's/.*topic\/([0-9]+).*/\1/')
if [ -z "$forum_topic_id" ]; then
  echo "Invalid forum topic URL, ID not found. Exiting.."
  exit 1
fi

if [ ! -f "$changelog_file" ]; then
    echo "$changelog_file does not exist. Exiting.."
    exit 1
fi


# Set up
echo "Logging in.."
user_agent="Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/81.0 KSP2ForumGithubAction/0.1"
index_response=$(curl 'https://forum.kerbalspaceprogram.com/' -c ./cookies)
csrf_token=$(echo $index_response | pup 'input[name="csrfKey"] attr{value}') 

login_response=$(curl -X POST -L -d "auth=${INPUT_USERNAME}&password=${INPUT_PASSWORD}&csrfKey=${csrf_token}&_processLogin=usernamepassword" -A "$user_agent" -b ./cookies -c ./cookies 'https://forum.kerbalspaceprogram.com/login/')
csrf_token=$(echo $index_response | pup 'input[name="csrfKey"] attr{value}') 

logged_username=$(echo "$login_response" | pup 'a#elUserLink text{}' | tr -d ' ')
echo "Logged in as: $logged_username"
if [ -z "$logged_username" ]; then
  echo "Login failed. Exiting.."
  exit 1
fi

# Message: add release title
echo $'\Prepare post message..'

echo "## Release v${INPUT_VERSION}" > ./message.md
cat "$changelog_file" >> ./message.md

if [ ! -z "$INPUT_SPACEDOCK_URL" ]; then
    echo "[See on SpaceDock](${INPUT_SPACEDOCK_URL})" >> ./message.md
else

if [ ! -z "$INPUT_POST_FOOTER" ]; then
  echo "$INPUT_POST_FOOTER" >> ./message.md
fi

pandoc -f markdown -t html './message.md' > message.html
tr -d '\n' < message.html > messagestripped.html # \r\n on Windows

# message_escaped=$(echo "$message_html" | jq -sRr '@uri')
# echo "HTML OK, Message:"
# echo "$message_escaped"

echo $'\nGet forum topic..'
latest_page_response=$(curl -L -A "$user_agent" -b ./cookies -c ./cookies "${forum_topic_url}pages/9999")

csrf_token=$(echo $latest_page_response | pup 'div[data-role="replyArea"] input[name="csrfKey"] attr{value}')
plupload_input=$(echo $latest_page_response | pup 'div[data-role="replyArea"] input[name="plupload"] attr{value}')
maxfilesize_input=$(echo $latest_page_response | pup 'div[data-role="replyArea"] input[name="MAX_FILE_SIZE"] attr{value}')

echo $'\nUpdate title..'
new_title=$(echo "$INPUT_TOPIC_TITLE" | sed -e "s/{version}/${INPUT_VERSION}/")
echo "New title: $new_title"
title_response=$(curl -X POST -L \
--data-urlencode "newTitle=${new_title}" \
--data-urlencode "csrfKey=${csrf_token}" \
--data-urlencode "do=ajaxEditTitle" \
-A "$user_agent" -b ./cookies -c ./cookies "${forum_topic_url}")

echo $'\nReply..' 
reply_response=$(curl -X POST -L \
-F _contentReply=1 \
-F MAX_FILE_SIZE=${maxfilesize_input} \
-F plupload=${plupload_input} \
-F csrfKey=${csrf_token} \
-F topic_auto_follow=0 \
-F commentform_${forum_topic_id}_submitted=1 \
-F "topic_comment_${forum_topic_id}=" \
-F "topic_comment_${forum_topic_id}_noscript=<messagestripped.html" \
-A "$user_agent" -b ./cookies -c ./cookies "$forum_topic_url")

rm ./cookies

echo $'\nDone!'