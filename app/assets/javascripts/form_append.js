function appendField() {
  var new_div = document.createElement("div");
  new_div.className = "form-group";

  var new_input_field = document.createElement("input");
  new_input_field.type = "text";
  new_input_field.className = "form-control";
  new_input_field.name = "batch_ids[]";

  new_div.append(new_input_field);
  document.getElementById("batch_id_form").appendChild(new_div);
}

window.onload = function() {
  var the_form = document.getElementById("add_batch_id_field");

  if(the_form) {
    the_form.onclick = appendField;
  }
}
