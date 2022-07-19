# yearn-workflows
Github actions workflows

## Stuck on grabbing lock
The multisig workflow grabs a "lock" to prevent 2 runs from writing the same nonce.

If you find your run stuck at the lock grabbing step, then follow these steps:

1. Check the Github Actions workflows page for any active jobs that are running at the same time as yours. If so, wait for them to complete.
2. If there are no other jobs running, then check the repo for a branch called `actions-mutex-lock/send-eth` (note: replace eth with whatever network you are using). Double check no other jobs are running and then manually delete the branch, either through Github's UI or via this command `git push origin --delete actions-mutex-lock/send-eth` 
3. Your job should then resume automatically once that branch is deleted.
