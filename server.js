const express = require('express');
const cors = require('cors'); // Import the cors middleware
const fs = require('fs');
const path = require('path');

const directoryPath = '/home/feynlan/utility/snapshots/cascadia';
const heightFilePath = path.join(directoryPath, 'height');

const app = express();

// Use the cors middleware with default options
app.use(cors());

app.get('/info', (req, res) => {
    const files = fs.readdirSync(directoryPath);
    const latestFile = files.filter(file => file.includes('cascadia_') && file.endsWith('.tar')).sort().reverse()[0];
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

const server = app.listen(8999, () => {
    console.log('Server listening on port 8999');
});