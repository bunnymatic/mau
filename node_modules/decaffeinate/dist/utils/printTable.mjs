export default function printTable(table, buffer) {
    if (buffer === void 0) { buffer = ' '; }
    var widths = [];
    table.rows.forEach(function (row) {
        row.forEach(function (cell, i) {
            if (widths.length <= i) {
                widths[i] = cell.length;
            }
            else if (widths[i] < cell.length) {
                widths[i] = cell.length;
            }
        });
    });
    var output = '';
    table.rows.forEach(function (row) {
        row.forEach(function (cell, i) {
            var column = table.columns[i];
            if (column.align === 'left') {
                output += cell;
            }
            else if (column.align === 'right') {
                output += ' '.repeat(widths[i] - cell.length) + cell;
            }
            if (i < row.length - 1) {
                output += buffer;
            }
        });
        output += '\n';
    });
    return output;
}
