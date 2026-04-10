#-----------------------------------------------------------------------------------------------------
#
#   Project - kubemic-install
#   Description:
#       A python installation package for umic@microk8s
#   Author: devhliu@image.local.com
#   Created 2022-07-20
#
#-----------------------------------------------------------------------------------------------------

import os
import docker
import subprocess

from glob import glob

#-----------------------------------------------------------------------------------------------------
#
def retrieve_registry_from_docker_tag(docker_tag):
    """
    """
    tags = docker_tag.split(':')
    version = tags[-1]
    taglabel = docker_tag.replace(':' + version, '')
    image_infos = taglabel.split('/')
    image_name = image_infos[-1]
    registry = taglabel.replace('/' + image_name, '')
    return registry, image_name, version
#-----------------------------------------------------------------------------------------------------
#
def add_tag_docker_images(old_registry, old_image_name, old_version,
                          new_registry, new_image_name, new_version):
    """
    """
    old_tag = old_registry + '/' + old_image_name + ':' + old_version
    new_tag = new_registry + '/' + new_image_name + ':' + new_version
    cmd = ['docker', 'tag', old_tag, new_tag]
    subprocess.call(cmd)
    return
#-----------------------------------------------------------------------------------------------------
#
def save_docker_images(image_tag, save_path):
    """
    """
    image_filename = image_tag.replace('/', '--')
    image_filename = image_filename.replace(':', '--')
    image_file = os.path.join(save_path, image_filename + '.tar')
    # if os.path.exists(image_file): return
    cmd = ['docker', 'save', image_tag, '-o', image_file]
    subprocess.call(cmd)
    
    return
#-----------------------------------------------------------------------------------------------------
#
def remove_docker_images(image_tag):
    """
    """
    cmd = ['docker', 'rmi', image_tag]
    subprocess.call(cmd)
    
    return
#-----------------------------------------------------------------------------------------------------
#
def upload_to_microk8s(image_tar):
    """
    """
    cmd = ['microk8s.ctr', 'image', 'import', image_tar]
    subprocess.call(cmd)
    return
#-----------------------------------------------------------------------------------------------------
#
def docker_push_to_harbor(docker_image_tag):
    cmd = ['docker', 'push', docker_image_tag]
    subprocess.call(cmd)
    return
#-----------------------------------------------------------------------------------------------------
#
#   main entry
#
#-----------------------------------------------------------------------------------------------------
if __name__ == '__main__':

    # docker iamge storage root
    # docker_image_tar_root = '/app/umic-release/offline-repos'
    # current_registry_name = 'k8s.gcr.io'
    # docker_image_storage_root = os.path.join(docker_image_tar_root, current_registry_name)
    # os.makedirs(docker_image_storage_root, exist_ok=True)

    # client = docker.from_env()
    client = docker.DockerClient(base_url='unix://var/run/docker.sock')

    # get list of available images
    registry_1 = 'registry.local.org/umic-kaapana'
    docker_images = client.images.list()
    for docker_image in docker_images:
        for img_tag in docker_image.tags:
            registry_0, image_name_0, version_0 = retrieve_registry_from_docker_tag(img_tag)
            
            if not registry_0 == 'registry.local.org/umic/kaapana': continue
            print(registry_0, image_name_0, version_0)
