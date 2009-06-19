// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

replace_ids = function(s){
  var new_id = new Date().getTime();
  return s.replace(/NEW_RECORD/g, new_id);
}

var myrules = {
  '.remove': function(e){
    el = Event.findElement(e);
    target = el.href.replace(/.*#/, '.')
    el.up(target).hide();
    if(hidden_input = el.previous("input[type=hidden]")) hidden_input.value = '1'
  },
  '.add_nested_item': function(e){
    el = Event.findElement(e);
    template = eval(el.href.replace(/.*#/, ''))
    $(el.rel).insert({
      bottom: replace_ids(template)
    });
  },
  '.add_nested_item_lvl2': function(e){
    el = Event.findElement(e);
    elements = el.rel.match(/(\w+)/g)
    parent = '.'+elements[0]
    child = '.'+elements[1]

    child_container = el.up(parent).down(child)
    parent_object_id = el.up(parent).down('input').name.match(/.*\[(\d+)\]/)[1]

    template = eval(el.href.replace(/.*#/, ''))

    template = template.replace(/(attributes[_\]\[]+)\d+/g, "$1"+parent_object_id)

   // console.log(template)
    child_container.insert({
      bottom: replace_ids(template)
     });
  }
};

Event.observe(window, 'load', function(){
  $('container').delegate('click', myrules);
});

function add_child_item(el, depth) {
  try {
    var id_children_str = "";
    var name_children_str = "request[request_items][]";
    for (i = 0; i < depth; i++) {
      id_children_str += "_request_items_";
      name_children_str += "[children][]";
    }

    var html = '\n<label for="request_new_request_items__request_amount">Request amount</label>\n';
    html += '<input id="request' + id_children_str + '_request_amount" name="' + name_children_str + '[request_amount]" size="30" type="text">\n';
//    html += '<input id="request' + id_children_str + '_should_destroy" name="request[request_items][]' + name_children_str + '[should_destroy]" value="0" type="hidden" class="should_destroy">\n';
    html += '<a href="#" onclick="this.up().hide()">remove</a><br />\n';
    html += '<a href="#" onclick="add_child_item(this.up(), ' + (depth + 1) + '); return false;">add child item</a>\n\n';

    var div = document.createElement("div");
    div.innerHTML = html;
    div.addClassName("request_item");
    div.id = "new_" + new Date().getTime();
    div.style.margin = "10px 0px 10px 40px";
    if (depth == 1) {
      div.setStyle({backgroundColor: "#e6e6e6", padding: "10px", border: "1px solid #888", marginLeft: "0px"});
    }

    el.insert({ bottom: div });
  }
  catch (e) {
    alert('RJS error:\n\n' + e.toString());
    alert('x');
    throw e;
  }
}

// set the request_node_id in the URL to create a new request_item
function new_item_url(node_id) {
  if (node_id == "") return;
  var url = "" + window.location;
  if (url.charAt(url.length - 1) != "/") url += "/";
  url += "new?node_id=" + node_id;
  window.location = url;
}

