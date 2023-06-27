// Load the AWS SDK for Node.js
var AWS = require('aws-sdk');
// Create DynamoDB service object
var ddb = new AWS.DynamoDB({apiVersion: '2012-08-10'});

var groupBy = function(xs, key) {
  return xs.reduce(function(rv, x) {
    (rv[x[key].S] = rv[x[key].S] || []).push(x);
    return rv;
  }, {});
};


module.exports.handler = async function (event, context, callback) {
    var params = {
        TableName: 'images'
    };

    let data = await ddb.scan(params).promise();

    let groupedEntries = groupBy(data.Items,"email")

    for (const [key, value] of Object.entries(groupedEntries)) {
        groupedEntries[key] = {
            "count":value.length,
            "score_sum":value.reduce((partialSum, a) => partialSum + parseInt(a.score.N), 0)
        }
    }

    return groupedEntries;
}