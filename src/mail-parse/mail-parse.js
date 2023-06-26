'use strict';
var AWS = require('aws-sdk');
var s3 = new AWS.S3();
var ddb = new AWS.DynamoDB({apiVersion: '2012-08-10'});
var bucketName = process.env.BUCKET;
var simpleParser = require('mailparser').simpleParser;
module.exports.handler = async function (event, context, callback) {
    console.log('Event: ', JSON.stringify(event));
    var s3Object = event.Records[0].s3.object;
    var s3Bucket = event.Records[0].s3.bucket;
    // Retrieve the email from your bucket
    var req = {
        Bucket: s3Bucket.name,
        Key: s3Object.key
    };
    const data = await s3.getObject(req).promise();

    console.log("Raw email:\n" + data.Body);

    // Custom email processing goes here
    const parsed = await simpleParser(data.Body);

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
    const returndata = await s3.putObject(params).promise();
        
    const client = new AWS.Rekognition();
    const detectParams = {
    Image: {
        S3Object: {
            Bucket: "aws-bbq-images-dev-ireland", 
            Name: s3Object.key+parsed.attachments[0].filename,
        },
    },
    MaxLabels: 1000
    }
    const detections = await client.detectLabels(detectParams).promise();
    
    detections.Labels.forEach(label => {
        console.log(`Label:      ${label.Name}`)
        console.log(`Confidence: ${label.Confidence}`)
        console.log("Instances:")
        label.Instances.forEach(instance => {
            console.log(`  Confidence: ${instance.Confidence}`)
        })
        console.log("Parents:")
        label.Parents.forEach(parent => {
            console.log(`  ${parent.Name}`)
        })
        console.log("------------")
        console.log("")
    
    }) // for response.labels

    
    // Word list generated by https://relatedwords.io/api/relatedTerms?term=meat
    const WordMatches = require('./bbq-words');
    const score = detections.Labels.map(w=> {
        let parentMatchTotal = 0;
        let matchesFound = WordMatches.words.some(bbqWord=>{
            let bbq = bbqWord.term.toLowerCase();
            let detected = w.Name.toLowerCase();
            return bbq.includes(detected) || detected.includes(bbq);
        });
        matchesFound = matchesFound || w.Parents.some(parentword=>{
            WordMatches.words.some(bbqWord=>{
                let bbq = bbqWord.term.toLowerCase();
                let detected = parentword.Name.toLowerCase();
                let isMatch = bbq.includes(detected) || detected.includes(bbq);
                if (isMatch) parentMatchTotal = parentMatchTotal + 1;
                return isMatch;
            });
        });
        if (matchesFound){
            console.log(`Word match: ${w.Name}`)
            return (w.Instances ? Math.max(w.Instances.length,1):1)+parentMatchTotal;
        } else {
            return 0;
        }
    }).reduce((a,b)=>a+b);
    console.log(`Score: ${score}`)
    var params = {
        TableName:"images",
        Item: {
            id : {S: s3Object.key}, 
            email : {S:  parsed.from.text},
            image_location : {S:s3Object.key+parsed.attachments[0].filename},
            score : {N:score.toString()},
            // data : {M:JSON.stringify(detections)}
        }
    };
    console.log("Storing:", data);
    
    const dbputresponse = await ddb.putItem(params).promise();
    console.log("Item entered successfully");

    // Create sendEmail params 
    var emailParams = {
    Destination: { /* required */
      ToAddresses: [
        parsed.from.value[0].address
      ]
    },
    Message: { /* required */
      Body: { /* required */
        Text: {
         Charset: "UTF-8",
         Data: score>0?`Nice work, I think you had a decent BBQ. I rate it a ${score}`:"Your pathetic attempt at a BBQ does not register on my BBQ-o-meter. "
        }
       },
       Subject: {
        Charset: 'UTF-8',
        Data: 'Your BBQ'
       }
      },
    Source: 'ratemy@bbq.benoxley.com', /* required */
    ReplyToAddresses: [
       'ratemy@bbq.benoxley.com',
      /* more items */
    ],
  };
  
  // Create the promise and SES service object
  await new AWS.SES({apiVersion: '2010-12-01'}).sendEmail(emailParams).promise();

    
    callback(null, null);
}
