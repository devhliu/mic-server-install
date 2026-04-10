# save and load docker images

> docker save image:tag | gzip > image--tag.tar.gz
> gunzip -c image--tag.tar.gz | docker load
