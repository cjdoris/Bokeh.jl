const DataSource = ModelType("DataSource";
    abstract = true,
)

const ColumnarDataSource = ModelType("ColumnarDataSource";
    abstract = true,
    inherits = [DataSource],
)

const ColumnDataSource = ModelType("ColumnDataSource";
    inherits = [ColumnarDataSource],
    props = [
        :data => ColumnDataT(),
        :column_names => GetSetT(x->collect(String,keys(x.data))),
    ],
)

const CDSView = ModelType("CDSView";
    props = [
        :filters => ListT(AnyT()),
        :source => InstanceT(ColumnarDataSource),
    ],
)
