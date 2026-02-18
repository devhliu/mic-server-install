
- https://gist.github.com/Kevinrob/4c7f1e5dbf6ce4e94d6ba2bfeff37aeb

registry=localhost:32000
repositories=$(curl ${registry}/v2/_catalog)
for repo in $(echo "${repositories}" | jq -r '.repositories[]'); do
  echo $repo
  tags=$(curl -sSL "http://${registry}/v2/${repo}/tags/list" | jq -r '.tags[]')
  for tag in $tags; do
    echo $tag
    curl -v -sSL -X DELETE "http://${registry}/v2/${repo}/manifests/$(
      curl -sSL -I \
          -H "Accept: application/vnd.docker.distribution.manifest.v2+json" \
          "http://${registry}/v2/${repo}/manifests/$tag" \
      | awk '$1 == "Docker-Content-Digest:" { print $2 }' \
      | tr -d $'\r' \
    )"
  done
done