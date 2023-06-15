'use strict';
var AWS = require('aws-sdk');
var s3 = new AWS.S3();
var bucketName = process.env.BUCKET;
var simpleParser = require('mailparser').simpleParser;
module.exports.handler = function (event, context, callback) {
    console.log('Event: ', JSON.stringify(event));
    var s3Object = event.Records[0].s3.object;
    var s3Bucket = event.Records[0].s3.bucket;
    // Retrieve the email from your bucket
    var req = {
        Bucket: s3Bucket.name,
        Key: s3Object.key
    };
    s3.getObject(req, function (err, data) {
        if (err) {
            console.log(err, err.stack);
            callback(err);
        } else {
            console.log("Raw email:\n" + data.Body);
// Custom email processing goes here
            simpleParser(data.Body, (err, parsed) => {
                if (err) {
                    console.log(err, err.stack);
                    callback(err);
                } else {
                    console.log("headers:", parsed.headers);
                    console.log("date:", parsed.date);
                    console.log("subject:", parsed.subject);
                    console.log("body:", parsed.text);
                    console.log("from:", parsed.from.text);
                    console.log("attachments:", parsed.attachments);
                    var params = {
                        Body: parsed.attachments[0].content, 
                        Bucket: "aws-bbq-images-dev-ireland", 
                        Key: s3Object.key+parsed.attachments[0].filename,
                       };
                    s3.putObject(params, function(err, data) {
                        if (err) console.log(err, err.stack); // an error occurred
                        else     console.log(data);           // successful response
                        const client = new AWS.Rekognition();
                    const detectParams = {
                    Image: {
                        S3Object: {
                            Bucket: "aws-bbq-images-dev-ireland", 
                            Name: s3Object.key+parsed.attachments[0].filename,
                        },
                    },
                    MaxLabels: 10
                    }
                    client.detectLabels(detectParams, function(err, response) {
                    if (err) {
                        console.log(err, err.stack); // if an error occurred
                    } else {
                        response.Labels.forEach(label => {
                        console.log(`Label:      ${label.Name}`)
                        console.log(`Confidence: ${label.Confidence}`)
                        console.log("Instances:")
                        label.Instances.forEach(instance => {
                            let box = instance.BoundingBox
                            console.log("  Bounding box:")
                            console.log(`    Top:        ${box.Top}`)
                            console.log(`    Left:       ${box.Left}`)
                            console.log(`    Width:      ${box.Width}`)
                            console.log(`    Height:     ${box.Height}`)
                            console.log(`  Confidence: ${instance.Confidence}`)
                        })
                        console.log("Parents:")
                        label.Parents.forEach(parent => {
                            console.log(`  ${parent.Name}`)
                        })
                        console.log("------------")
                        console.log("")
                        }) // for response.labels
                    } // if
                    });
                        
                        callback(null, null);
                    });
                                        
                    
                }
            });
        }
    });
};