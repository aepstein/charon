// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function mark_to_destroy(el) {
  destroy_fields = el.select(".should_destroy");
  for (i = 0; i < destroy_fields.length; i++) {
    destroy_fields[i].value = "1";
  }
  el.hide();
}

function add_child_item(el, depth) {
  try {
    var id_children_str = "";
    var name_children_str = "";
    for (i = 0; i < depth; i++) {
      id_children_str += "_request_items_";
      name_children_str += "[children][]";
    }

    var html = '\n<label for="request_new_request_items__request_amount">Request amount</label>\n';
    html += '<input id="request' + id_children_str + '_request_amount" name="request[request_items][]' + name_children_str + '[request_amount]" size="30" type="text">\n';
    html += '<input id="request' + id_children_str + '_should_destroy" name="request[request_items][]' + name_children_str + '[should_destroy]" value="0" type="hidden" class="should_destroy">\n';
    html += '<a href="#" onclick="mark_to_destroy(this.up()); return false;">remove</a><br />\n';
    html += '<a href="#" onclick="add_child_item(this.up(), ' + (depth + 1) + '); return false;">add child item</a>\n\n';

    var div = document.createElement("div");
    div.innerHTML = html;
    div.addClassName("item");
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

