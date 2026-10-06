*** Settings ***
Library     QForce

*** Variables ***
# Maximum time to wait for org recovery before giving up (10 minutes)
${MAINTENANCE_WAIT_TIMEOUT}    600s
# Pause between each availability probe (30 seconds)
${MAINTENANCE_POLL_PAUSE}      30s

*** Keywords ***

# ── Core Availability Probe ──────────────────────────────────────────────────

Poll Until Org Is Available
    [Documentation]    Single-attempt availability probe used exclusively by RunBlock.
    ...                Pauses 30 s, refreshes, then asserts the URL is no longer
    ...                the maintenance page. RunBlock retries from the top on failure.
    Sleep               ${MAINTENANCE_POLL_PAUSE}
    RefreshPage
    ${url}=             GetUrl
    Should Not Contain  ${url}    maintenanceandavailable.jsp
    ...    Salesforce org is still on the maintenance page. Will retry in ${MAINTENANCE_POLL_PAUSE}...

# ── Guard Keyword (call this after any navigation) ───────────────────────────

Check For Maintenance Page
    [Documentation]    Reads the current URL. If the Salesforce maintenance page
    ...                (maintenanceandavailable.jsp) is detected, captures a screenshot,
    ...                logs a warning, and enters a polling loop (RunBlock) to wait for
    ...                recovery. Fails with a descriptive message if the org does not
    ...                recover within MAINTENANCE_WAIT_TIMEOUT.
    ${current_url}=     GetUrl
    ${on_maintenance}=  Evaluate    'maintenanceandavailable.jsp' in '${current_url}'
    IF    ${on_maintenance}
        LogScreenshot
        Log    MAINTENANCE DETECTED. Org is temporarily unavailable.    level=WARN
        Log    Current URL: ${current_url}                              level=WARN
        Log    Waiting up to ${MAINTENANCE_WAIT_TIMEOUT} for recovery...  level=WARN
        TRY
            RunBlock    Poll Until Org Is Available    timeout=${MAINTENANCE_WAIT_TIMEOUT}
        EXCEPT
            Fail
            ...    SALESFORCE ORG MAINTENANCE TIMEOUT: The org did not recover within
            ...    ${MAINTENANCE_WAIT_TIMEOUT}. Maintenance URL was: ${current_url}.
            ...    Check https://status.salesforce.com for the incident status and
            ...    re-run the suite once the org is back online.
        END
    END

# ── Enhanced Login Appstate with Built-in Guard ──────────────────────────────

SF_JWT_Login
    [Documentation]    Authenticates via JWT, navigates to Salesforce home, then
    ...                immediately checks for the maintenance page before handing
    ...                control to any test step.
    [Arguments]    ${client_id}=${jwt_client_id}
    ...            ${user}=${username}
    ...            ${key}=${private_key}
    JwtAuthenticate     ${client_id}    ${user}    ${key}
    JwtLogin            /lightning/page/home
    Check For Maintenance Page