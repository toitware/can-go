package version

import (
	"testing"
	"text/scanner"

	"github.com/toitware/can-go/pkg/dbc/analysis"
	"github.com/toitware/can-go/pkg/dbc/analysis/analysistest"
)

func TestAnalyzer(t *testing.T) {
	analysistest.Run(t, Analyzer(), []*analysistest.Case{
		{
			Name: "ok",
			Data: `VERSION ""`,
		},

		{
			Name: "not ok",
			Data: `VERSION "foo"`,
			Diagnostics: []*analysis.Diagnostic{
				{
					Pos:     scanner.Position{Line: 1, Column: 1},
					Message: "version should be empty",
				},
			},
		},
	})
}
