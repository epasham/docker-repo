import os

from g import templates_dir
from .configs import parse_versions
from .jinja import render_jinja

docker_compose_template_path = os.path.join(templates_dir, 'docker_compose', 'docker-compose.yml.jinja')
docker_compose_yml_path = '/compose_location/docker-compose.yml'

# render docker-compose
def prepare_docker_compose(configs, with_clair, with_notary, with_chartmuseum):
    versions = parse_versions()
    VERSION_TAG = versions.get('VERSION_TAG') or 'dev'
    REGISTRY_VERSION = versions.get('REGISTRY_VERSION') or 'v2.7.1'
    NOTARY_VERSION = versions.get('NOTARY_VERSION') or 'v0.6.1'
    CLAIR_VERSION = versions.get('CLAIR_VERSION') or 'v2.0.7'
    CHARTMUSEUM_VERSION = versions.get('CHARTMUSEUM_VERSION') or 'v0.8.1'

    rendering_variables = {
        'version': VERSION_TAG,
        'reg_version': "{}-{}".format(REGISTRY_VERSION, VERSION_TAG),
        'redis_version': VERSION_TAG,
        'notary_version': '{}-{}'.format(NOTARY_VERSION, VERSION_TAG),
        'clair_version': '{}-{}'.format(CLAIR_VERSION, VERSION_TAG),
        'chartmuseum_version': '{}-{}'.format(CHARTMUSEUM_VERSION, VERSION_TAG),
        'data_volume': configs['data_volume'],
        'log_location': configs['log_location'],
        'protocol': configs['protocol'],
        'http_port': configs['http_port'],
        'registry_custom_ca_bundle_path': configs['registry_custom_ca_bundle_path'],
        'with_notary': with_notary,
        'with_clair': with_clair,
        'with_chartmuseum': with_chartmuseum
    }

    storage_config = configs.get('storage_provider_config') or {}
    if storage_config.get('keyfile'):
        rendering_variables['gcs_keyfile'] = storage_config['keyfile']
    if configs.get('https_port'):
        rendering_variables['https_port'] = configs['https_port']

    if configs['protocol'] == 'https':
        rendering_variables['cert_key_path'] = configs['cert_key_path']
        rendering_variables['cert_path'] = configs['cert_path']

    render_jinja(docker_compose_template_path, docker_compose_yml_path, **rendering_variables)