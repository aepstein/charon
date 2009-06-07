Factory.define :request_structure do |request_structure|
  Factory.sequence :request_structure do |sequence|
    "request_structure##{sequence}"
  end
  request_structure.name = Factory.next :request_structure_name
end

Factory.define :request_node do |request_node|
  request_node.association :request_structure
end

