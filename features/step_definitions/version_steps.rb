Given /^the following versions:$/ do |versions|
  versions.hashes.each do |version|
    version_object = Factory.build(:version, version)
    version_object.requestable = Factory(version_object.item.node.requestable_type.underscore.to_sym)
    version_object.save
  end
end

