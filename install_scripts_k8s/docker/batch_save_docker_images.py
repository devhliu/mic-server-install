import os
import docker

docker_image_tar_root = '/mnt/d/umic/app/umic-release/build/20230201/container-images'
registry_name = 'mirecon-dataserver.image.local.com:61443'

# client = docker.from_env()
client = docker.DockerClient(base_url='unix://var/run/docker.sock')

# get list of available images
docker_images = client.images.list()
for docker_image in docker_images:
    for img_tag in docker_image.tags:
        if not img_tag.startswith(registry_name): continue
        # print('working on saving %s - %s'%(docker_image.id, img_tag))
        img_tar_filename = img_tag.replace('/', '--')
        img_tar_filename = img_tar_filename.replace(':', '--')
        img_tar_filename = img_tar_filename + '.tar'
        img_tar_file = os.path.join(docker_image_tar_root, img_tar_filename)
        if os.path.isfile(img_tar_file): 
            print('done with saving %s.'%(img_tag))
            continue
        try:
            f_img_tar = open(img_tar_file, 'wb')
            for chunk in docker_image.save(): f_img_tar.write(chunk)
            f_img_tar.close()
            print('done with saving %s.'%(img_tag))
        except:
            print('# ---------# there is an error when saving %s.'%(img_tag))
            if os.path.isfile(img_tar_file): os.remove(img_tar_file)
