const express = require('express');
const cors = require('cors'); // Import the cors middleware
const fs = require('fs');
const path = require('path');
const https = require('https');
const morgan = require('morgan');

const directoryPath = '/home/feynlan/utility/snapshots/cascadia';
const options = {
    key: fs.readFileSync('/etc/letsencrypt/live/snapshot.cascadia.foundation/privkey.pem'),
    cert: fs.readFileSync('/etc/letsencrypt/live/snapshot.cascadia.foundation/fullchain.pem')
  };


const heightFilePath = path.join(directoryPath, 'height');

const app = express();

// Use the cors middleware with default options
app.use(cors());
app.use(morgan(':remote-addr - :method :url :status :response-time ms'));


// Route 
app.get('/snapshots/cascadia/info', (req, res) => {
    const files = fs.readdirSync(directoryPath);
    const latestFile = files.filter(file => file.includes('cascadia_') && file.endsWith('.tar.lz4')).sort().reverse()[0];
    const filePath = path.join(directoryPath, latestFile);
    const stat = fs.statSync(filePath);

    const fileInfo = {
        filename: latestFile,
        size: stat.size,
        timestamp: stat.mtime, // add the timestamp property
        chainId: "cascadia_6102-1"
    };

    fs.readFile(heightFilePath, (err, data) => {
        if (err) {
            console.error(err);
            res.status(500).send('Error reading height file');
            return;
        }

        fileInfo.blockheight = data.toString();
        res.status(200).json(fileInfo);
    });
});

app.get('/snapshots/:tarfilename', (req, res) => {
    const requestedFile = req.params.tarfilename;
    const filePath = path.join(directoryPath, requestedFile);
    const stat = fs.statSync(filePath);

    // Check if the file exists
    if (!fs.existsSync(filePath)) {
        res.status(404).send('File not found');
        return;
    }

    res.writeHead(200, {
        'Content-Type': 'application/x-tar',
        'Content-Length': stat.size,
        'Content-Disposition': `attachment; filename=${requestedFile}`
    });

    const readStream = fs.createReadStream(filePath);
    readStream.pipe(res);
});

const server = https.createServer(options, app).listen(8443, () => {
    console.log('Server listening on port 8443');
});