# ksp2-forum-post-action
GitHub Action to post mod update on KSP2 Forum and update topic title

## Usage

```
      - name: Update mod topic 
        uses: Kerbalight/ksp2-forum-post-action@latest
        with:
          username: ${{ secrets.KSP_FORUM_USERNAME }}
          password: ${{ secrets.KSP_FORUM_PASSWORD }}
          forum_topic_url: https://forum.kerbalspaceprogram.com/topic/...
          forum_topic_title: My Mod Name [v{version} for KSP2 v{ksp2_version}]
          spacedock_url: https://spacedock.info/...
          version: ${{ env.version }}
          changelog: ./changelog.md
```

- `username`: should be your forum login username. Store it in a GitHub Action Secret
- `password` should be your forum login password. Store it in a GitHub Action Secret
- `forum_topic_url`: URL of the forum topic to update. 
  - It's not relevant if the last part of the URL changes when title is updated, the important thing is topic ID (the number after "topic/")
- `forum_topic_title`: New title of the forum topic.
  - `{version}` will be replaced by the value of `version` input
  - `{ksp2_version}` will be replaced by the value of `ksp2_version.min` field set in **swinfo.json**. Remember to update this field in your mod's **swinfo.json** file before releasing.
- `spacedock_url`: URL of the mod on Spacedock.
  - It's optional, but it's recommended to include it to show a "Download on SpaceDock" link in the forum post.
- `version`: Version of the mod to update. Should always be `${{ env.version }}` to use the version set in the SpaceWarp template release
- `swinfo_path`. [**Optional**] Path to the **swinfo.json** file. Default is `plugin_template/swinfo.json`, as set in the SpaceWarp template