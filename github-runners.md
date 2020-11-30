# Github runners

Github runner nodes have to be manually configured to be connected to the desired github repository. 
Get a token from github.com and log in as `github-runner` on the node to do this:

```sh
CLUSTER_NAME=...
GITHUB_REPO=...
GITHUB_TOKEN=...

cd ~/actions-runner
./config.sh \
    --url "https://github.com/$GITHUB_REPO" \
	--name $(hostname -f) \
	--labels "$CLUSTER_NAME" \
	--work "$HOME/actions-workdir" \
	--token "$GITHUB_TOKEN"

sudo bash -c "$HOME/actions-runner/svc.sh install github-runner"
sudo mkdir -p "/etc/systemd/system/actions.runner.${GITHUB_REPO//\//-}.$(hostname -f).service.d"
sudo ln -s /opt/etc/systemd/github-runner-environment.conf "/etc/systemd/system/actions.runner.${GITHUB_REPO//\//-}.$(hostname -f).service.d/environment.conf"
sudo systemctl daemon-reload
sudo systemctl enable "actions.runner.${GITHUB_REPO//\//-}.$(hostname -f).service"
sudo systemctl start "actions.runner.${GITHUB_REPO//\//-}.$(hostname -f).service"
```
