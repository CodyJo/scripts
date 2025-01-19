# Define the base directory for Puppet code
$baseDir = "C:\Users\me\codyjoco"
Write-Host "Starting Puppet folder structure setup at $baseDir..." -ForegroundColor Cyan

# Define the directory structure
$directories = @(
    "$baseDir/environments/production/manifests",
    "$baseDir/environments/production/modules/my_module/manifests",
    "$baseDir/environments/production/modules/my_module/templates",
    "$baseDir/environments/production/modules/my_module/files",
    "$baseDir/environments/production/modules/my_module/lib/puppet",
    "$baseDir/environments/production/modules/my_module/lib/facter",
    "$baseDir/environments/production/hieradata/nodes",
    "$baseDir/environments/development/manifests",
    "$baseDir/environments/development/modules",
    "$baseDir/environments/development/hieradata"
)

# Create the directories with logging
foreach ($dir in $directories) {
    Write-Host "Creating directory: $dir" -ForegroundColor Green
    New-Item -Path $dir -ItemType Directory -Force | Out-Null
}

# Create default files with logging
function CreateFile {
    param (
        [string]$FilePath,
        [string]$Content
    )
    Write-Host "Creating file: $FilePath" -ForegroundColor Yellow
    New-Item -Path $FilePath -ItemType File -Force -Value $Content | Out-Null
}

CreateFile "$baseDir/environments/production/manifests/site.pp" @"
# site.pp - Main manifest file
node default {
    notify { 'Hello, Puppet!': }
}
"@

CreateFile "$baseDir/environments/production/modules/my_module/manifests/init.pp" @"
# init.pp - Main class for my_module
class my_module {
    include my_module::install
    include my_module::config
    include my_module::service
}
"@

CreateFile "$baseDir/environments/production/modules/my_module/manifests/install.pp" @"
# install.pp - Handles package installation
class my_module::install {
    package { 'my_package':
        ensure => installed,
    }
}
"@

CreateFile "$baseDir/environments/production/modules/my_module/manifests/config.pp" @"
# config.pp - Handles configuration
class my_module::config {
    file { '/etc/my_app/config.yaml':
        ensure  => file,
        content => template('my_module/my_config.epp'),
    }
}
"@

CreateFile "$baseDir/environments/production/modules/my_module/manifests/service.pp" @"
# service.pp - Manages service
class my_module::service {
    service { 'my_service':
        ensure => running,
        enable => true,
    }
}
"@

CreateFile "$baseDir/environments/production/modules/my_module/templates/my_config.epp" @"
# my_config.epp - Example template
config_key: <%= $config_value %>
"@

CreateFile "$baseDir/environments/production/modules/my_module/files/example.conf" @"
# example.conf - Example static file
key=value
"@

CreateFile "$baseDir/environments/production/modules/my_module/metadata.json" @"
{
    \"name\": \"my_module\",
    \"version\": \"0.1.0\",
    \"author\": \"Cody\",
    \"summary\": \"My custom module\",
    \"source\": \"https://github.com/my-org/my_module\",
    \"license\": \"Apache-2.0\",
    \"dependencies\": []
}
"@

CreateFile "$baseDir/environments/production/modules/my_module/README.md" @"
# My Module
This module manages the my_module service.
"@

CreateFile "$baseDir/environments/production/hieradata/common.yaml" @"
# common.yaml - Global hiera data
my_module::config::config_value: 'default_value'
"@

CreateFile "$baseDir/environments/production/environment.conf" @"
# environment.conf - Puppet environment configuration
modulepath = ./modules
"@

Write-Host "Puppet folder structure setup completed successfully!" -ForegroundColor Cyan
