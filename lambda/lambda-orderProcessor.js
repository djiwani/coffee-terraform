const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, PutCommand } = require("@aws-sdk/lib-dynamodb");
const { SNSClient, PublishCommand } = require("@aws-sdk/client-sns");

const dynamo = DynamoDBDocumentClient.from(new DynamoDBClient({ region: "us-east-1" }));
const sns = new SNSClient({ region: "us-east-1" });

exports.handler = async (event) => {
    try {
        const body = JSON.parse(event.body || '{}');
        const orderID = Date.now().toString();
        const order = {
            orderID,
            name: body.name || "unknown",
            drink: body.drink || "unknown",
            temperature: body.temperature || "unknown",
            size: body.size || "unknown",
            extras: body.extras || [],
            timestamp: new Date().toISOString()
        };

        await dynamo.send(new PutCommand({
            TableName: "fourallthedogs_coffeeorders",
            Item: order
        }));

        await sns.send(new PublishCommand({
            TopicArn: "arn:aws:sns:us-east-1:333859152383:coffee-orders-topic",
            Message: `New Order:
Name: ${order.name}
Drink: ${order.drink}
Temperature: ${order.temperature}
Size: ${order.size}
Extras: ${order.extras.join(", ")}
OrderID: ${order.orderID}`
        }));

        return {
            statusCode: 200,
            body: JSON.stringify(order)
        };

    } catch (err) {
        return {
            statusCode: 500,
            body: JSON.stringify({ message: err.message })
        };
    }
};