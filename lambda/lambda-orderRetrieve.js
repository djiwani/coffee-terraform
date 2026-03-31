const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, ScanCommand } = require("@aws-sdk/lib-dynamodb");

const dynamo = DynamoDBDocumentClient.from(new DynamoDBClient({ region: "us-east-1" }));

const ALLOWED_ORIGIN = "https://cafe.fourallthedogs.com";

exports.handler = async (event) => {
    try {
        const result = await dynamo.send(new ScanCommand({
            TableName: "fourallthedogs_coffeeorders"
        }));

        const items = result.Items || [];
        items.sort((a, b) => b.timestamp.localeCompare(a.timestamp));

        return {
            statusCode: 200,
            body: JSON.stringify(items)
        };

    } catch (error) {
        return {
            statusCode: 500,
            body: JSON.stringify({ message: "Internal server error" })
        };
    }
};