*** Settings ***

Documentation             New test suite
# You can change imported library to "QWeb" if testing generic web application, not Salesforce.
Library                   QForce
Library                   String
Library                   QWeb
Resource    resources/Keywors.robot
Suite Setup               Open Browser                about:blank                chrome
Suite Teardown            Close All Browsers
*** Variables ***
#${FirtName}
#${LastName}
#${FullName}
#${Company}
*** Test Cases ***
TC1:Lead Cration
    [Documentation]       This Test case is           to validate                the lead creation functionality
    Appstate              SF_JWT_Login

    VerifyText            Leads                       timeout=30
    ClickText             Leads
    ClickText             New                         partial_match=False
    UseModal              ON
    VerifyText            New Lead
    PickList              Salutation                  Sr.
    ${FirtName}=          Generate Random String      10                         [LETTERS]
    ${LastName}=          Generate Random String      10                         [LETTERS]
    ${Company}=           Generate Random String      10                         [LETTERS]
    Set Suite Variable    ${Company}
    ${FullName}=          Set variable                ${FirtName} ${LastName}
    Set Suite Variable    ${FullName}
    TypeText              First Name                  ${FirtName}
    TypeText              Last Name                   ${LastName}
    TypeText              Company                     ${Company}

    ClickText             Save                        partial_match=False

TC2:Lead Conversion
    VerifyText            Convert                     timeout=30
    ClickText             Convert
    UseModal              ON
    VerifyText            Convert Lead
    ClickText             Create New Account
    ClickText             Create New Contact
    ClickText             Create New Opportunity
    ClickText             Convert                     anchor=Cancel
    UseModal              On
    VerifyText            our lead has been converted
    #To Verify Account block
    VerifyText            Account
    VerifyText            ${Company}
    #To Verify Contact
    VerifyText            Contact
    VerifyText            ${FullName}                 anchor=Title:
    #To Verify Opportunity
    VerifyText            Opportunity
    ClickText             Cancel and close
    UseModal              Off

TC3: New Campaign page Validations
    [Documentation]    This TC is for validting the New Campaig page
    [Tags]             Campaign
    Appstate              SF_JWT_Login
    VerifyText            Campaigns
    ClickText             Campaigns    partial_match=False
    ClickText             New                         partial_match=False
    UseModal              ON
    VerifyText            New Campaign
    VerifyCheckboxValue                        Active    on

