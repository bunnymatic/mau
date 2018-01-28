/**
 * Maps a list to another list by combining lists.
 */
export default function flatMap(list, map) {
    return list.reduce(function (memo, item) { return memo.concat(map(item)); }, []);
}
