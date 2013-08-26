//= require load-image
//= require jquery.fileupload

$(function() {
  // prevent default browser drapdrop behavior
  $(document).bind('drop dragover', function (e) {
    e.preventDefault();
  });

  function setProgress(item, percent) {
    item.attr('aria-valuenow', percent)
      .find(".bar").css("width", percent + "%");
  }

  function setupFileField(inp) {
    var input = $(inp),
        form = input.parents("form"),
        attributeName = input.attr("data-attr-name"),
        modelName = input.attr("data-model-name"),
        container = form.find("." + attributeName),
        list = container.find("ul"),
        multiple = input.attr("multiple"),
        preview = form.find(input.attr("data-preview") || ".preview"),
        add = form.find(".add"),
        inputPrefix = modelName + "[" + attributeName + "_attributes]",
        inputName,
        autosubmit = input.attr("data-autosubmit"),
        url = input.attr("data-file-upload");

    if(multiple) {
      inputName = inputPrefix + "[REPLACE_ID][key]";
    } else {
      inputName = inputPrefix + "[key]";
    }

    input.fileupload({
      url: url,
      dataType: 'json',
      maxFileSize: 5000000,
      formData: function(form) { return []; },
      type: 'POST',
      // this is called after the files have been uploaded
      done: function(e, data) {
        // replace the input with a new one
        replaceInput(this);

        if(preview.length > 0) {
          window.loadImage(data.files[0], function(img) {
            preview.html(img);
          });
        }
        // add field with file id
        $.each(data.result.files, function(i, file) {
          // load preview
          if(multiple) {
            // add checkbox field
            var item = data.files[i].item;
            item.find(".progress").replaceWith(
              $('<input type="checkbox" checked="checked"/>')
                .attr('name', inputName.replace("REPLACE_ID", Math.floor(Math.random() * 1000000)))
                .val(file['id'])
            );
          } else {
            // add key hidden field
            container.find(".inputs .progress").replaceWith('<input type="hidden" name="' + inputName + '" value="' + file['id'] + '"/><input type="checkbox" checked="checked" name="' + inputPrefix + "[_destroy]" + '" value="0"/>');
          }
        });

        if(autosubmit) {
          form.submit();
        }
      },
      fail: function(e, data){
        replaceInput(this);

        if (data.jqXHR.status === 413) {
          message = 'The size limit is 10MB.';
        } else {
          message = 'Upload failed, please try again.';
        }
        container.find('.error').html(message);

        // data.files is 1-length array with the file of the ajax event
        $.each(data.files, function(i, file) {
          var item = data.files[i].item;
          item.remove();
        });
      },
      // this is called after selecting a file
      add: function(e, data) {
        // clear errors
        container.find('.error').html('');

        $.each(data.files, function(i, file) {
          if(multiple) {
            file.item = $("<li/>").append('<label class="checkbox"></label>');
            file.item.find('label').text(file.name + " (" + (Math.round(file.size/10.24)/100) + "kB)" )
              .prepend($("<div class='progress'><div class='bar'></div></div>"));
            file.item.appendTo(list);
          } else {
            var label = $("<label class='checkbox'></label").text(file.name + " (" + (Math.round(file.size/10.24)/100) + "kB)").prepend("<div class='progress'><div class='bar'></div></div>");
            container.find(".inputs").html(label);
          }
        });

        // do the ajax file upload
        data.submit();
      }
    });

    // file type limiting option
    if(input.attr("data-accept")) {
      input.fileupload("option", "acceptFileTypes", new RegExp(input.attr("data-accept"), "i"));
    }

    if(!add.data("input")) {
      add.click(function(evt) {
        $(this).data("input").click();
        evt.preventDefault();
        return false;
      });
    }
    add.data("input", input);

    input.trigger("upload:setupcomplete");
  }

  function replaceInput(inp) {
    var that = $(inp),
      clone = that.clone();
    that.replaceWith(clone);
    clone.trigger("upload:enable");
  }

  function handleSubmit(evt) {
    evt.preventDefault();
    return false;
  }

  function setupEach(evt) {
    $(this).each(function(i, el) {
      setupFileField(el);
    });
  }

  $('body').on("upload:enable", ":file[data-file-upload]", setupEach);
  $(":file[data-file-upload]").trigger("upload:enable");
});
