export default function notNull(t) {
    if (t === null || t === undefined) {
        throw new Error('Unexpected null value.');
    }
    return t;
}
