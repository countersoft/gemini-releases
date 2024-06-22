gemini_documentsApp = {
    projectId: 0,

    readOnly: false,

    init: function (temp_upload, temp_dropzone, temp_delete, selectedFolder, editPermission, temp_sizeexceeded)
    {        
        var height = gemini_sizing.availableHeight();   
        $('#geminiDocuments').height(height);

        gemini_documentsApp.projectId = $('#geminiDocuments #Projects1').val();

        if (!gemini_documentsApp.projectId)
        {
            return;
        }

        //gemini_documentsApp.readOnly = readOnlyList[gemini_documentsApp.projectId];

        if (editPermission == "True")
        {
            gemini_documentsApp.readOnly = false;            
        }
        else
        {
            gemini_documentsApp.readOnly = true;            
        }
       
        gemini_documentsApp.initDynaTree(selectedFolder);

        $('#geminiDocuments #Projects1').change(function ()
        {
            gemini_documentsApp.projectId = $(this).val();

            //gemini_documentsApp.readOnly = readOnlyList[gemini_documentsApp.projectId];

            $("#tree").dynatree('destroy');         

            gemini_documentsApp.initDynaTree();

            $("#page-documents #fileupload-hit").empty();

            if (!gemini_documentsApp.readOnly) {
                $('#geminiDocuments .or-drop-here').show();
                gemini_documentsApp.initFileUploader(temp_upload, temp_dropzone, temp_sizeexceeded, csVars.MaxFileSize);
            }
            else
            {
                $('#geminiDocuments .or-drop-here').hide();
            }

            $.extend(gemini_documentsApp.document_taxonomy, {
                uploadButton: temp_upload,
                dropZone: temp_dropzone,
                deleteText: temp_delete,
                sizeExceeded: temp_sizeexceeded
            });

            gemini_documentsApp.updateAppNavCard();
            var height = gemini_sizing.availableHeight();
            if (height < $('#geminiDocuments').height()) $('#geminiDocuments').height(height);
        });

        $.extend(gemini_documentsApp.document_taxonomy, {
            uploadButton: temp_upload,
            dropZone: temp_dropzone,
            deleteText: temp_delete,
            sizeExceeded: temp_sizeexceeded
        });        

        $('#geminiDocuments').off("blur", "#DocumentFolderRenamer input").on('blur', '#DocumentFolderRenamer input', function (e) {
            $("#DocumentFolderRenamer").fadeOut();
            $('#DocumentFolderRenamer #NewName').removeClass('error');

            var node = $("#tree").dynatree("getTree").selectKey('new');
            if (node) {
                node.remove();
                $('#dynatree-id-new').remove();
            }
        });

        gemini_documentsApp.document_uploader = null;

        if (gemini_documentsApp.readOnly)
        {
            $('#geminiDocuments .or-drop-here').hide();
            return;
        }

        gemini_documentsApp.initFileUploader(temp_upload, temp_dropzone, temp_sizeexceeded, csVars.MaxFileSize);
    },

    updateAppNavCard: function()
    {
        var node = $("#tree").dynatree("getActiveNode");

        gemini_appnav.pageCard.Options['1B9CB627-A2F2-4CC5-BE5B-D0FABB489F87'] = JSON.stringify({ projectId: gemini_documentsApp.projectId, folderKey: node ? node.data.Id : 0 });
    },

    initFileUploader: function (temp_upload, temp_dropzone, temp_sizeexceeded, maxUploadBytes)
    {
        gemini_documentsApp.document_uploader = new qq.FileUploader({
            element: $("#page-documents #fileupload-hit")[0],
            action: gemini_ajax.getUrl("apps/documents/", "UploadFile/" + gemini_documentsApp.projectId, true),
            debug: false,
            sizeLimit: maxUploadBytes,
            onComplete: function (_id, fileName, responseJSON) {
                //Fix for error szenario where object is empty. I.e. if file is to big, responseJSON will be empty, but will come to "onComplete"
                if (!jQuery.isEmptyObject(responseJSON)) {
                    // insert image into page
                    var id = responseJSON.fileId;
                    var folderid = responseJSON.folderId;
                    gemini_documentsApp.document_FolderList(folderid);
                }
            },
            showMessage: function(message) {
                gemini_popup.toast(message, true);
            },
            messages: {
                typeError: "{file} has invalid extension. Only {extensions} are allowed.",
                sizeError: temp_sizeexceeded,
                minSizeError: "{file} is too small, minimum file size is {minSizeLimit}.",
                emptyError: "{file} is empty, please select files again without it.",
                onLeave: "The files are being uploaded, if you leave now the upload will be cancelled."
            },
            taxonomy: {
                uploadButton: temp_upload,
                dropZone: temp_dropzone
            }
        });
        
        $(document).off('click', "span.delete-action");
        $(document).off('click', "span.refresh-action");
        $(document).off('click', "span.description-action");        

        if (!gemini_documentsApp.readOnly)
        {
            $(document).on('click', "span.delete-action", function () {
                var id = $(this).attr("data-id");
                var itemText = $(this).closest("tr").children("td:eq(0)").children("a").text();
                gemini_commons.translateMessage("[[Delete]] " + itemText + "?", ['Delete'], function (message) {
                    gemini_popup.modalConfirm(message, null,
                            function () {
                                gemini_ui.startBusy('#modal-confirm #modal-button-yes');
                                gemini_ajax.call("apps/documents/", "DeleteDocument/" + gemini_documentsApp.projectId, gemini_documentsApp.document_removeDocument, function () { gemini_ui.stopBusy('#modal-confirm #modal-button-yes'); }, { documentId: id }, null, true);
                            }
                        );
                });


            });
            
            $(document).on('click', "span.refresh-action", function () {
                var id = $(this).attr("data-id");

                $(".qq-upload-button input").prop('multiple', '');
                gemini_documentsApp.document_uploader.setParams({ documentId: id });

                $(".qq-upload-button input").click();
                $(".qq-upload-button input").prop('multiple', 'multiple');

            });

            $(document).on('click', "span.description-action", function () {

                //remove all other textboxes
                var inputs = $(this).closest("table").find("td input:text");

                $.each(inputs, function (index, item) {
                    $(item).parent().html($(item).val());
                });

                var id = $(this).attr("data-id");
                var td_description = $(this).closest("tr").children("td:eq(1)");
                var td_updatedDate = $(this).closest("tr").children("td:eq(3)");
                var text = td_description.text();

                var tb = $("<input type='text' name='document-description' id='document-description' class='width-100' value='" + text + "'></input>");
                tb.bind('blur', function () {
                    td_description.html(text);
                });
                gemini_commons.inputKeyHandler(tb,
                    function () {
                        var newtext = $(tb).val();

                        gemini_ajax.postCall("apps/documents/", "savedescription/" + gemini_documentsApp.projectId, function (response) {
                            if (response.Success) {

                                td_description.empty();
                                td_description.html(newtext);
                                td_updatedDate.empty();
                                td_updatedDate.html(response.Result.Data);
                            }
                            else {
                                td_description.empty();
                            }
                        }, null, { fileId: id, description: newtext }, null, true);

                    },
                    function () {
                        td_description.html(text);
                    }
                );
                td_description.empty().append(tb);
                tb.focus();
            });
        }
    },

    initDynaTree: function (selectedFolder)
    {
        gemini_commons.inputKeyHandlerUnbind('#DocumentFolderRenamer input');
        gemini_commons.inputKeyHandler("#DocumentFolderRenamer input",
                function ()
                {
                    // return key
                    var id = $("#DocumentFolderRenamer #NodeId").val();
                    var parentId = $("#DocumentFolderRenamer #ParentNodeId").val();
                    var newName = $("#DocumentFolderRenamer #NewName").val();
                    if (newName.length == 0)
                    {
                        $('#DocumentFolderRenamer #NewName').addClass('error');
                        return;
                    }
                    gemini_documentsApp.document_FolderRename(id, newName, parentId);
                    $("#DocumentFolderRenamer").fadeOut();
                },
                function ()
                {
                    //escape
                    $("#DocumentFolderRenamer").fadeOut();
                    var node = $("#tree").dynatree("getTree").selectKey("new");
                    if (node)
                        node.remove();
                }
            );

        $("#tree").dynatree({
            onActivate: function (n)
            {
                gemini_documentsApp.document_FolderList(n.data.key);
                gemini_documentsApp.updateAppNavCard();
            },
            debugLevel: 0,
            persist: false,
            generateIds: true, //important for inline editing to work
            clickFolderMode: 1,
            fx: { height: "toggle", duration: 200 },
            initAjax: {
                url: gemini_ajax.getUrl("apps/documents/", "LoadTree/" + gemini_documentsApp.projectId, true),
                data: null
            },
            onRender: function ()
            {
                if (!gemini_documentsApp.readOnly)
                {
                    gemini_documentsApp.contextMenu(".dynatree-node");
                }
            },
            onPostInit: function (isReloading, isError)
            {
                var nodeList = $("#tree").dynatree("getRoot").getChildren();

                var node;
                for (var i = 0; i < nodeList.length; i++) {
                    if (!nodeList[i].isStatusNode())
                    {
                        node = nodeList[i];
                    }
                }

                if (selectedFolder && $('#dynatree-id-' + selectedFolder).length > 0)
                    $('#geminiDocuments #dynatree-id-' + selectedFolder).click();
                else
                    $('#geminiDocuments .dynatree-lastsib:eq(0)').click();
            }
        });
    },

    document_taxonomy: {},

    document_removeDocument: function (response)
    {
        gemini_ui.stopBusy('#modal-confirm #modal-button-yes');

        if (response.Success)
        {
            var id = response.Result.Data.id;            
            $("#filelist-container tr[data-id='" + id + "']").remove();

            if ($("#filelist-container tr").length == 0)
            {
                var node = $("#tree").dynatree("getActiveNode");
                if (node)
                {
                    gemini_documentsApp.document_FolderList(node.data.Id);
                }
            }
        }    
    },

    document_uploader: null,

    document_FolderListed: function (response)
    {
        $("#page-documents #filelist-container").html(response);
    },

    document_FolderList: function (key)
    {
        if (gemini_documentsApp.document_uploader != null) {
            gemini_documentsApp.document_uploader.setParams({ folderId: key });
        }
        var opts = {
            key: key
        };
        gemini_ajax.call("apps/documents/", "GetFolderContents/" + gemini_documentsApp.projectId, gemini_documentsApp.document_FolderListed, null, opts, null, true);
    },

    document_FolderRename: function (key, newName, parent)
    {
        var opts = {
            key: key == "new" ? -1 : key,
            name: newName,
            parent: parent
        };
        if (parent > 0)
            gemini_ajax.call("apps/documents/", "rename/" + gemini_documentsApp.projectId, gemini_documentsApp.document_FolderCreated, null, opts, null, true);
        else
            gemini_ajax.call("apps/documents/", "rename/" + gemini_documentsApp.projectId, gemini_documentsApp.document_FolderRenamed, null, opts, null, true);
    },

    document_FolderCreated: function (response)
    {
        var node = $("#tree").dynatree("getTree").selectKey("new");
        var parentId = response.Result.Data.BaseEntity.ParentDocumentId;
        node.remove();

        node = $("#tree").dynatree("getTree").selectKey(parentId);

        node.addChild({
            title: response.Result.Data.BaseEntity.Name,
            key: response.Result.Data.BaseEntity.Id,
            isFolder: response.Result.Data.BaseEntity.IsFolder,
            expand: false //true if all folders are expanded
        });
    },

    document_FolderRenamed: function (response)
    {
        var node = $("#tree").dynatree("getTree").selectKey(response.Result.Data.BaseEntity.Id);
        node.data.title = response.Result.Data.BaseEntity.Name;
        node.render();
    },

    document_FolderDeleted: function (key)
    {
        var tree = $("#tree").dynatree("getTree");

        tree.selectKey(key).remove();        

        if ($('#geminiDocuments .dynatree-container li:first').length > 0)
            $('#geminiDocuments .dynatree-container li:first').click();
        else
        {
            location.reload();
        }
    },

    document_FolderDeleting: function (node)
    {
        //alert("Delete " + node.data.title);
        gemini_ajax.call("apps/documents/", "DeleteFolder/" + gemini_documentsApp.projectId,
            function () {
                gemini_documentsApp.document_FolderDeleted(node.data.key);
            }, null, { folderId: node.data.key }, null, true);
    },

    document_menuRenameFolder: function (element, parent)
    {
        var elem = $(element);
        var id = elem.parent("li").attr("id").replace("dynatree-id-", "");
        var node = $("#tree").dynatree("getTree").selectKey(id);
        var namer = $("#DocumentFolderRenamer");

        namer.show();
        var offset = elem.offset();
                
        namer.position({
            "my": "left top",
            "at": "left top",
            "of": elem,
            "offset": "+35 -2",
            "collision": "none"
        });        

        var folders = $("#folders").width() - elem.position().left - 38;
        namer.css("width", folders);

        namer.children("input").val(node.data.title).focus().select();
        namer.children("#NodeId").val(id);
        namer.children("#ParentNodeId").val(parent);
    },

    document_menuCreateFolder: function (element)
    {
        var elem = $(element);
        var id = elem.parent("li").attr("id").replace("dynatree-id-", "");
        var node = $("#tree").dynatree("getTree").selectKey(id);

        var childNode = node.addChild({
            title: "",
            key: "new",
            isFolder: true
        });
        node.expand();

        var el = $("#dynatree-id-new span");

        gemini_documentsApp.document_menuRenameFolder(el, id);
    },

    document_menuDeleteFolder: function (element)
    {
        var elem = $(element);
        var id = elem.parent("li").attr("id").replace("dynatree-id-", "");
        var node = $("#tree").dynatree("getTree").selectKey(id);

        gemini_popup.modalConfirm(gemini_documentsApp.document_taxonomy.deleteText + ": " + node.data.title, null,
            function () {
                gemini_documentsApp.document_FolderDeleting(node);
            }
            , null);
    },

    /*****************************************
    *** Right click menu
    *****************************************/
    contextMenu: function (selector)
    {       
        $(selector, '#doc-pane').contextMenu({ menu: 'document-folder-context-menu' },
            function (action, el, pos)
            {
                if (action == "view")
                {
                    // nothing here for now
                    //console.log(elem);
                }
                else if (action == "new")
                {
                    gemini_documentsApp.document_menuCreateFolder(el);
                }
                else if (action == "edit")
                {
                    gemini_documentsApp.document_menuRenameFolder(el, null);
                }
                else if (action == "delete")
                {
                    gemini_documentsApp.document_menuDeleteFolder(el);
                }
            },
            function (before) {
            }
        );
    }
};