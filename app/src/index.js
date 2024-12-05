import express from 'express';
import morgan from 'morgan';
import path from 'path';

const app = express();
const PORT = 80

app.use(morgan(':method :url :status :res[content-length] - :response-time ms'));

app.get('/', (_, res) => {
    res.sendFile(path.join(import.meta.dirname, 'templates/index.html'));
});

app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});