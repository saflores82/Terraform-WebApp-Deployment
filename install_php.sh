#!/bin/bash
 
cd /var/www/html
 
# Actualiza los paquetes e instala Apache
sudo yum install php  php-cli php-json  php-mbstring  –y
sudo php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"


# Inicia Apache y habilita para que inicie en cada reinicio del sistema
sudo php composer-setup.php
sudo php -r "unlink('composer-setup.php');"
sudo php composer.phar require aws/aws-sdk-php

# Reiniciar Apache
sudo service httpd restart

echo "<!DOCTYPE html>
<html lang='en'>
<head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>Contact Form</title>
</head>
<body>
    <h1>Contact Form</h1>
    <form action='submit.php' method='POST'>
        <label for='name'>Name:</label><br>
        <input type='text' id='name' name='name' required><br>
        <label for='email'>Email:</label><br>
        <input type='email' id='email' name='email' required><br>
        <label for='message'>Message:</label><br>
        <textarea id='message' name='message' rows='4' required></textarea><br>
        <input type='submit' value='Submit'>
    </form>
</body>
</html>
" | sudo tee index.html > /var/www/html



echo "<?php
require 'vendor/autoload.php';
 
use Aws\Sns\SnsClient;
use Aws\Exception\AwsException;
 
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $name = $_POST['name'];
    $email = $_POST['email'];
    $message = $_POST['message'];
 
    // Replace 'your-sns-topic-arn' with the ARN of your SNS topic
    $snsTopicArn = 'arn:aws:sns:us-east-1:891377380166:Gatos:e40be007-8b0a-4f9e-9dbc-914ecc8548c2';
 
    // Initialize SNS client
    $snsClient = new SnsClient([
        'version' => 'latest',
        'region' => 'us-east-1' // Replace with your desired AWS region
    ]);
 
    // Create message to send to SNS topic
    $messageToSend = json_encode([
        'email' => $email,
        'name' => $name,
        'message' => $message
    ]);
 
    try {
        // Publish message to SNS topic
        $snsClient->publish([
            'TopicArn' => $snsTopicArn,
            'Message' => $messageToSend
        ]);
 
        echo 'Message sent successfully.';
    } catch (AwsException $e) {
        echo 'Error sending message: ' . $e->getMessage();
    }
} else {
    http_response_code(405);
    echo 'Method Not Allowed';
}
?>

" | sudo tee submit.php > /var/www/html