# Remove installed version, if it's not the one that should be installed.
# We only support one user space nodejs installation

PACKAGE_BASENAME = "opsworks-nodejs"
LECAGY_PACKAGES = []

pm_helper = OpsWorks::PackageManagerHelper.new(node)
current_package_info = pm_helper.summary(PACKAGE_BASENAME)

if current_package_info.version && current_package_info.version =~ /^#{node[:opsworks_nodejs][:version]}.#{node[:opsworks_nodejs][:pkgrelease]}/
  Chef::Log.info("Userspace NodeJS version is up-to-date (#{node[:opsworks_nodejs][:version]} release #{node[:opsworks_nodejs][:pkgrelease]})")
else

  packages_to_remove = pm_helper.installed_packages.select do |pkg, version|
    pkg.include?(PACKAGE_BASENAME) || LECAGY_PACKAGES.include?(pkg)
  end

  packages_to_remove.each do |pkg, version|
    package "Remove outdated package #{pkg}" do
      package_name pkg
      action :remove
    end
  end

  log "downloading" do
    message "Download and install NodeJS version #{node[:opsworks_nodejs][:full_version]} patch #{node[:opsworks_nodejs][:patch]} release #{node[:opsworks_nodejs][:pkgrelease]}"
    level :info

    action :nothing
  end

  opsworks_commons_assets_installer "Install user space OpsWorks NodeJS package" do
    asset PACKAGE_BASENAME
    version node[:opsworks_nodejs][:version]
    release node[:opsworks_nodejs][:pkgrelease]

    notifies :write, "log[downloading]", :immediately
    action :install
  end

  if node[:opsworks_npm][:version]
    log "downloading" do
      message "Update npm"
      level :info

      action :nothing
    end

    execute "npm update" do
        command "npm install -g npm@v#{node[:opsworks_npm][:version]}"
    end
  end
end
