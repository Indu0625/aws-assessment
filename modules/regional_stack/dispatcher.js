const AWS = require("aws-sdk");
const ecs = new AWS.ECS();

exports.handler = async () => {
  try {
    const region = process.env.AWS_REGION;

    await ecs.runTask({
      cluster: process.env.CLUSTER_NAME,
      taskDefinition: process.env.TASK_DEF,
      launchType: "FARGATE",
      networkConfiguration: {
        awsvpcConfiguration: {
          subnets: [process.env.SUBNET_ID],
          securityGroups: [process.env.SG_ID],
          assignPublicIp: "ENABLED"
        }
      }
    }).promise();

    return {
      statusCode: 200,
      body: JSON.stringify({
        message: "ECS task triggered",
        region: region
      })
    };

  } catch (error) {
    return {
      statusCode: 500,
      body: JSON.stringify({
        error: error.message
      })
    };
  }
};
