const AWS = require("aws-sdk");

const dynamo = new AWS.DynamoDB.DocumentClient();

exports.handler = async () => {
  try {
    const region = process.env.AWS_REGION;

    // Write to DynamoDB
    await dynamo.put({
      TableName: process.env.TABLE_NAME,
      Item: {
        id: Date.now().toString(),
        region: region,
        timestamp: new Date().toISOString()
      }
    }).promise();

    return {
      statusCode: 200,
      body: JSON.stringify({
        message: "Success",
        region: region
      })
    };

  } catch (error) {
    console.error("ERROR:", error);

    return {
      statusCode: 500,
      body: JSON.stringify({
        message: "Internal Server Error",
        error: error.message
      })
    };
  }
};