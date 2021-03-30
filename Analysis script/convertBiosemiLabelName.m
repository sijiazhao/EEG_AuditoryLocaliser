function y = convertBiosemiLabelName(x)
t = readtable('table_biosemi64_label.csv');
y = cell(size(x));
for i = 1:length(x)
    y{i} = t.biosemi{strcmp(t.AB,x{i})};
end
