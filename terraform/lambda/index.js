const AWS = require('aws-sdk');
const dynamoDB = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
    const params = {
        TableName: 'TextTable',
        Key: {
            id: '1'  
        }
    };

    try {
        const data = await dynamoDB.get(params).promise();
        return {
            statusCode: 200,
            body: JSON.stringify(data.Item)
        };
    } catch (error) {
        return {
            statusCode: 500,
            body: JSON.stringify({ error: 'Could not retrieve item' })
        };
    }
};
