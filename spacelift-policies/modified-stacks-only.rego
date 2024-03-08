package spacelift

import rego.v1

track if {
  affected
  input.push.branch == input.stack.branch
}

propose if { affected }
propose if { affected_pr }

ignore if {
    not affected
    not affected_pr
}
ignore if { input.push.tag != "" }

affected if {
    some files in input.push.affected_files
    regex.match(sprintf("^%s/[^/]*$", [input.stack.project_root]), files)
}

affected_pr if {
    some files in input.pull_request.diff
    regex.match(sprintf("^%s/[^/]*$", [input.stack.project_root]), files)
}

sample := true
