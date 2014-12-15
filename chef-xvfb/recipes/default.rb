redhat_platform = ["redhat", "centos", "fedora"].include?(node["platform"])
if redhat_platform
  package "xorg-x11-server-Xvfb"
else
  package "xvfb"
end

template "/etc/init.d/xvfb" do
  source "xvfb.init.erb"
  mode "0755"
  variables(:redhat_platform => redhat_platform)
end

service "xvfb" do
  action [:start, :enable]
end
