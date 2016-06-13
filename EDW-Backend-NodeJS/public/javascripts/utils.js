
Array.prototype.unique = function()
{
    var n = {},r=[];
    for(var i = 0; i < this.length; i++) 
    {
        if (!n[this[i]]) 
        {
            n[this[i]] = true; 
            r.push(this[i]); 
        }
    }
    return r;
}

exports.getItemdate = function (categories, title, data){
    var item = {
        title: title,
        data:[]
    }
    for(var i=0; i< categories.length; i++){
        item.data[i] = [
            i,
            data[categories[i]]==null? 0:data[categories[i]]
        ]
    }
    return item;
}

exports.getDrilldowndata = function (categories, drilldownCategories, data){
    var item = []
    for (var i=0; i< categories.length; i++){
        item[i] = []
        for (var j=0; j< drilldownCategories.length ; j++){
            if(data[drilldownCategories[j]] != null ){
                item[i][j] = data[drilldownCategories[j]][categories[i]]
            }else{
                item[i][j] = null
            }
            
        }
    }
    return item
}
