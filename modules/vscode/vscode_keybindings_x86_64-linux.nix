[
  {
    key = "alt+=";
    command = "editor.action.commentLine";
    when = "editorTextFocus && !editorReadonly";
  }
  {
    key = "alt+o";
    command = "editor.action.formatDocument";
    when = "editorHasDocumentFormattingProvider && editorTextFocus && !editorReadonly && !inCompositeEditor";
  }
  {
    key = "alt+l";
    command = "editor.action.formatDocument";
    when = "editorHasDocumentFormattingProvider && editorTextFocus && !editorReadonly && !inCompositeEditor";
  }
  {
    key = "alt+w";
    command = "editor.action.toggleWordWrap";
  }
  {
    key = "ctrl+d";
    command = "editor.action.duplicateSelection";
  }

  # tut nicht
  # { key = "alt+#"; command = "workbench.action.moveEditorToRightGroup"; }
  {
    key = "alt+h";
    command = "workbench.action.moveEditorToRightGroup";
  }

  {
    key = "alt+-";
    command = "workbench.action.moveEditorToBelowGroup";
  }
  {
    key = "alt+v";
    command = "workbench.action.moveEditorToBelowGroup";
  }

  {
    key = "alt+d";
    command = "workbench.action.moveEditorToFirstGroup";
  }
  {
    key = "alt+x";
    command = "workbench.action.closeActiveEditor";
  }

  {
    key = "alt+up";
    command = "workbench.action.focusAboveGroup";
  }
  {
    key = "alt+down";
    command = "workbench.action.focusBelowGroup";
  }
  {
    key = "alt+left";
    command = "workbench.action.focusLeftGroup";
  }
  {
    key = "alt+right";
    command = "workbench.action.focusRightGroup";
  }

  {
    key = "alt+e";
    command = "workbench.action.openRecent";
  }

  {
    key = "alt+f";
    command = "workbench.action.findInFiles";
  }
  {
    key = "alt+f";
    command = "-workbench.action.findInFiles";
  }
  {
    key = "alt+f";
    command = "workbench.action.toggleSidebarVisibility";
    when = "searchViewletVisible";
  }
  {
    key = "alt+f";
    command = "-workbench.action.toggleSidebarVisibility";
    when = "searchViewletVisible";
  }

  {
    key = "alt+1";
    command = "workbench.view.explorer";
  }
  {
    key = "alt+1";
    command = "-workbench.view.explorer";
  }
  {
    key = "alt+1";
    command = "workbench.action.toggleSidebarVisibility";
    when = "explorerViewletVisible";
  }
  {
    key = "alt+1";
    command = "-workbench.action.toggleSidebarVisibility";
    when = "explorerViewletVisible";
  }

  {
    key = "ctrl+r";
    command = "editor.action.startFindReplaceAction";
    when = "editorFocus || editorIsOpen";
  }
]
