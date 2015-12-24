name             'my_web_app'
maintainer       'Skyscape Cloud Services'
maintainer_email 'rcoward@skyscapecloud.com'
license          'apache2'
description      'Installs/Configures my_web_app'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.3.0'

depends 'database'
depends 'mysql2_chef_gem', '~> 1.0'
depends 'mysql', '~> 6.0'
depends 'nginx'
depends 'php-fpm'
