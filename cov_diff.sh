#!/bin/bash

diff_cov_output="$(git diff ../codecov-main.txt ./codecov.txt | sed -E -n '/^(---|\+\+\+|@@)/!p' | tail -n +3)"
diff_cov_output="\`\`\`diff $diff_cov_output \`\`\`"
diff_cov_output="${diff_cov_output//'%'/'%25'}"
diff_cov_output="${diff_cov_output//$'\n'/'%0A'}"
diff_cov_output="${diff_cov_output//$'\r'/'%0D'}"

echo "::set-output name=covdiff::$diff_cov_output"
