function init() as void
    m.top.paused = false
    ' Claim focus so the Scene receives the Play/Pause remote key during the run.
    ' (Without focus, key events are dropped before reaching onKeyEvent.)
    m.top.setFocus(true)
end function

' Toggle paused state on the Play/Pause remote key.
'
' This handler runs on the render thread, so it can update UI nodes
' immediately while the main thread is still busy running tests. That gives
' us instant visual feedback ("Pausing — finishing current suite...") even
' though the actual pause kicks in only at the next suite boundary.
function onKeyEvent(key as string, press as boolean) as boolean
    if not press then return false
    if key <> "play" then return false

    ' Pause is only meaningful while tests are running. Once TestRunner
    ' publishes its final result, the run is over — ignore further presses.
    if m.top.rooibosTestResult <> invalid then return false

    m.top.paused = not m.top.paused
    spinner = m.top.findNode("resultSpinner")
    statusLabel = m.top.findNode("statusLabel")

    if m.top.paused then
        ' Pause requested. Suite still finishing — dim the spinner and tell
        ' the user that we're winding down rather than already stopped.
        if spinner <> invalid then spinner.opacity = 0.35
        if statusLabel <> invalid then statusLabel.text = "Pausing — finishing current suite..."
    else
        ' Resuming. Restore spinner opacity; the main thread re-starts the
        ' spinInterval and the next suite's setCurrentSuite() will overwrite
        ' the status label naturally.
        if spinner <> invalid then spinner.opacity = 1.0
    end if

    return true
end function
