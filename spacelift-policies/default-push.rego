package spacelift

track {
  affected
  input.push.branch == input.stack.branch
}

propose { affected }
propose { affected_pr }

ignore  {
    not affected
    not affected_pr
}
ignore  { input.push.tag != "" }

affected {
    filepath := input.push.affected_files[_]
    startswith(filepath, input.stack.project_root)
}

affected_pr {
    filepath := input.pull_request.diff[_]
    startswith(filepath, input.stack.project_root)
}

sample := true
