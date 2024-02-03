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
          forum_topic_title: My Mod Name [v{version} for KSP2 vXYZ]
          spacedock_url: https://spacedock.info/...
          version: ${{ env.version }}          
          changelog: ./changelog.md
```