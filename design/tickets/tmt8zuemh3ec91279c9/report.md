# Build report

```
Generating VERILOG via Gemini (thinking on, models auto-discovered).
--- attempt 1/3 ---
candidate models (newest first): ['gemini-3.7-flash', 'gemini-3.6-flash', 'gemini-3.5-flash', 'gemini-3.5-flash-lite', 'gemini-3.1-pro-preview', 'gemini-3.1-pro-preview-customtools', 'gemini-3.1-flash-lite-preview', 'gemini-3.1-flash-lite', 'gemini-3-flash-preview', 'gemini-2.5-flash', 'gemini-2.5-pro', 'gemini-2.5-flash-lite', 'gemini-flash-latest', 'gemini-pro-latest', 'gemini-omni-flash-preview', 'gemini-flash-lite-latest']
model gemini-3.7-flash unavailable: HTTP Error 503: Service Unavailable b'{\n  "error": {\n    "code": 503,\n    "message": "This model is currently experiencing high demand. Spikes in demand are usually temporary. Please try again later.",\n    "status": "UNAVAILABLE"\n  }\n}\n'
model used: gemini-3.6-flash
attempt 1 failed:

dut.v:12: syntax error
dut.v:12: error: Incomprehensible case expression.

--- attempt 2/3 ---
model gemini-3.7-flash unavailable: HTTP Error 503: Service Unavailable b'{\n  "error": {\n    "code": 503,\n    "message": "This model is currently experiencing high demand. Spikes in demand are usually temporary. Please try again later.",\n    "status": "UNAVAILABLE"\n  }\n}\n'
model used: gemini-3.6-flash
simulation OK on attempt 2
schematic: ok
```
