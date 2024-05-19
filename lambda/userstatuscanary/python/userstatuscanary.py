def basic_custom_script():
    # Insert your code here
    # Perform multi-step pass/fail check
    # Log decisions made and results to /tmp
    # Be sure to wait for all your code paths to complete 
    # before returning control back to Synthetics.
    # In that way, your canary will not finish and report success
    # before your code has finished executing

    fail = False
    if fail:
        raise Exception("Failed userstatus canary check.")
    
    return "Successfully completed userstatus canary checks."

def handler(event, context):
    return basic_custom_script()
