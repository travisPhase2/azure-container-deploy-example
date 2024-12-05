import express from 'express';
import morgan from 'morgan';
import path, { dirname } from 'path';
import { fileURLToPath } from 'url';

const app = express();
const PORT = 80
app.use(morgan(':method :url :status :res[content-length] - :response-time ms'));

app.get('/', (_, res) => {
    const fileName = fileURLToPath(import.meta.url);
    const dirName = dirname(fileName)

    res.sendFile(path.join(dirName, 'templates/index.html'));
});

app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});