function filterData(data, key, value) {
  var result = [];
  data.forEach(function(val,idx,arr){
    if(val[key] == value){
      result.push(val)
    }
  })
  // d3.selectAll('.mouse-per-line').remove();
  return result;
}

var x;
var y;
// Set the dimensions of the canvas / graph
var margin = {top: 30, right: 20, bottom: 60, left: 50},
    width = 1200 - margin.left - margin.right,
    height = 670 - margin.top - margin.bottom;


// Parse the date / time
var parseDate = d3.time.format("%b %Y").parse;
var formatDate = d3.time.format("%b %d %Y").parse

var div = d3.select("body").append("div")
    .attr("class", "tooltip")
    .style("opacity", 0);

var svg = d3.select("#linegraph")
  .append("svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
  .append("g")
      .attr("transform",
            "translate(" + margin.left + "," + margin.top + ")");

d3.selection.prototype.moveToFront = function() {
  return this.each(function(){
    this.parentNode.appendChild(this);
  });
};

var data;

d3.csv("datamanual.csv", function(error,csv) {
  csv.forEach(function(d) {
    d.date = formatDate(d.date.toString());
    d.price = +d.price;
  });
  data = csv;
  d3.select("#sent")
    .on("change", function(){
        var sect = document.getElementById("sent");
				var section = sect.options[sect.selectedIndex].value;
        if (section != 'sentiment'){
          data = filterData(csv, 'sent', section);
        } else {
          data = csv;
        }
	      //debugger
		    data.forEach(function(d) {
          d.date = d.date;
          d.price = +d.price;
    			d.active = true;
    		});
        //update the graph when filtered
				updateGraph(data);
				jQuery('h1.page-header').html(section);

    });
  d3.select("#inds")
    .on("change", function(){
        var sect = document.getElementById("inds");
				var section = sect.options[sect.selectedIndex].value;
        if (section != 'industry'){
          data = filterData(csv, 'inds', section);
          console.log("after",data);
        } else {
          data = csv;
        }
	      //debugger
		    data.forEach(function(d) {
          d.date = d.date;
          d.price = +d.price;
    			d.active = true;
    		});
        //update the graph when filtered
				updateGraph(data);
				jQuery('h1.page-header').html(section);

      });
    updateGraph(data);
  });



// updateGraph(data);

var color = d3.scale.category20();;

function updateGraph(data) {
  // Set the ranges
  x = d3.time.scale().range([0, width]);
  y = d3.scale.linear().range([height, 0]);

  // var fullBtn = document.getElementById("full_data");

  // Define the axes
  var xAxis = d3.svg.axis().scale(x)
      .orient("bottom").ticks(5);

  var yAxis = d3.svg.axis().scale(y)
      .orient("left").ticks(10);

  // Define the line
  priceline = d3.svg.line()
      .interpolate("cardinal")
      .x(function(d) { return x(d.date); })
      .y(function(d) { return y(d.price); })
  // Adds the svg canvas
      x.domain(d3.extent(data, function(d) {
        // console.log("d.date",d.date);
        return d.date; }));
      y.domain([d3.min(data, function(d) {
        // console.log("d.price", d.price);
        return d.price; }), d3.max(data, function(d) { return d.price; })]);

      // Nest the entries by symbol
      var dataNest = d3.nest()
          .key(function(d) {return d.symbol;}) //change to name
          .entries(data)

      var zoom = d3.behavior.zoom()
        .x(x)
        .y(y)
        .scaleExtent([1,8])
        .on("zoom", zoomed);

      svg.call(zoom);

      var result = dataNest.filter(function(val,idx, arr){
				  return $("." + val.key).attr("fill") != "#ccc"
				  // matching the data with selector status
				})

        var position = new Array();
             data.forEach(function(element) {
               if (element.mention == '1') {
                 position.push({symbol:element.symbol, mention: element.mention, price: element.price, date: element.date, tweet: element.tweet, sent: element.sent})
               }
             })

      //creates vertical line + data of point
      svg.selectAll("path").remove();
      mouseline(data);

      // Loop through each symbol / key
      var values = svg.selectAll(".line")
        .data(result, function(d){
          return d.key});

          toolTip(values, data, position);


      values.transition()
  			.style("stroke", function(d,i) { return d.color = color(d.key); })
  			.attr("id", function(d){
          return 'tag'+d.key.replace(/\s+/g, '');}) // assign ID
  			.attr("d", function(d){
  				return priceline(d.values)
  			});


      values.exit().remove();

      svg.selectAll(".axis").remove();


      //Add the X Axis
       var gX = svg.append("g")
           .attr("class", "x axis")
           .attr("transform", "translate(0," + height + ")")
           .call(xAxis);

       // Add the Y Axis
       var gY = svg.append("g")
           .attr("class", "y axis")
           .call(yAxis)
           .append("text")
           .attr("transform", "rotate(-90)")
           .attr("y", 6)
           .attr("dy", ".71em")
           .style("text-anchor", "end")
           .style ("stroke", "#C1BEBE")
           .text("Price in USD");

    function zoomed() {
      svg.select(".x.axis").call(xAxis);
      svg.select(".y.axis").call(yAxis);

      svg.selectAll("image")
        .attr("x", function(d,i){return x(d.date)})
        .attr("y",function(d,i){return y(d.price)});

      // toolTip(values, data, position)

      svg.selectAll(".line")
        .attr("class","line")
      	.attr("d", function (d) { return priceline(d.values)});
     	}
}

function mouseline(data,position) {
  svg.selectAll(".mouse-per-line").remove();
  var lines = document.getElementsByClassName('line');

  var dataNest = d3.nest()
      .key(function(d) {return d.symbol;}) //change to name
      .entries(data)

  var mouseG = svg.append("g")
    .attr("class", "mouse-over-effects");

  mouseG.append("path") // this is the black vertical line to follow mouse
    .attr("class", "mouse-line")
    .style("stroke", "white")
    .style("stroke-width", "1px")
    .style("opacity", "0");


  var mousePerLine = mouseG.selectAll('.mouse-per-line')
    .data(dataNest)
    .enter()
    .append("g")
    .attr("class", "mouse-per-line");

  // mousePerLine.append("circle")
  //   .attr("r", 4)
  //   .style("stroke", function(d) {
  //     return color(d.symbol);
  //   })
  //   .style("fill", "none")
  //   .style("stroke-width", "1px")
  //   .style("opacity", "0");

  mousePerLine.append("text")
    .attr("stroke", "white")
    .attr("transform", "translate(10,3)");

  mouseG.append('svg:rect') // append a rect to catch mouse movements on canvas
    .attr('width', width) // can't catch mouse events on a g element
    .attr('height', height)
    .attr('fill', 'none')
    .attr('pointer-events', 'all')
    .on('mouseout', function() { // on mouse out hide line, circles and text
      d3.select(".mouse-line")
        .style("opacity", "0");
      d3.selectAll(".mouse-per-line circle")
        .style("opacity", "0");
      d3.selectAll(".mouse-per-line text")
        .style("opacity", "0");
    })
    .on('mouseover', function(d) { // on mouse in show line, circles and text
      d3.select(".mouse-line")
        .style("opacity", "1");
      d3.selectAll(".mouse-per-line circle")
        .style("opacity", "1");
      d3.selectAll(".mouse-per-line text")
        .style("opacity", "1");
      // d3.selectAll("image").classed("image--fade",false);
    })
    .on('mousemove', function() { // mouse moving over canvas
      var mouse = d3.mouse(this);
      d3.select(".mouse-line")
        .attr("d", function() {
          var d = "M" + mouse[0] + "," + height;
          d += " " + mouse[0] + "," + 0;
          return d;
        });

      d3.selectAll(".mouse-per-line")
        .attr("transform", function(d, i) {
          var xDate = x.invert(mouse[0]),
              bisect = d3.bisector(function(d) { return d.date; }).right;
              idx = bisect(d.values, xDate);

          var beginning = 0,
              target = null;
          if (lines[i] != null) {
            var end = lines[i].getTotalLength();
          }
          while (true){
            target = Math.floor((beginning + end) / 2);
            pos = lines[i].getPointAtLength(target);
            if ((target === end || target === beginning) && pos.x !== mouse[0]) {
                break;
            }
            if (pos.x > mouse[0]){
              end = target;
            }
            else if (pos.x < mouse[0]) {
              beginning = target;
            }
            else break; //position found
          }
          // console.log("abc", y.invert(pos.y).toFixed(2));
          d3.select(this).select('text')
            .text(y.invert(pos.y).toFixed(2));
          // d3.selectAll("image").classed("image--fade",true);
          // datavalue = d.key
          // console.log("datavalue",datavalue);
          return "translate(" + mouse[0] + "," + pos.y +")";
        });
  });

}

function toolTip(values, data, position){
  svg.selectAll("image").remove();
  svg.selectAll(".dot").remove();


  //tooltip for trump's face
  var points = svg.selectAll(".point-container")
    .data(data, function(d) { if (d.mention == 1) {return d;}})
    .enter().append("path")
    .attr("class", "dot")
    .select("circle")
    .data(position)
    .enter().append("image")
    .attr('xlink:href', 'trump.png')
    .attr("id", function(d){
      if (d.mention == 1) { return d.symbol.toString();}})
    .attr("width",20)
    .attr("height",20)
    .attr("x", function(d,i) {
      if (d.mention == 1) { return x(d.date); }})
    .attr("y", function(d,i) {
      if (d.mention == 1) { return y(d.price); }})
    .on("mouseover", function(d) {
      var sel = d3.select(this);
      sel.moveToFront();
      d3.select(d.line).classed("line--hover", true);
      d3.selectAll(".line").classed("line--hover", function() {
        var id = this.id.substring(3);
        return (id == d.symbol);
      }).classed("line--fade", function() {
        var id = this.id.substring(3);
        return (id != d.symbol);
      });
      date = d.date.toString().split(" ");
      date = date[1] + " " + date[3];
      d3.select(this).attr("height", 60).attr("width", 60)
      d3.selectAll("image").classed("image--hover", function() {
        return (this.id == d.symbol);
      }).classed("image--fade", function() {
        return (this.id != d.symbol);
      });
      d3.select(".mouse-line")
        .style("opacity", "1");
      div.transition()
         .duration(200)
         .style("opacity", .9);
       div.html(date + "<br/>" + d.symbol + "<br/>" + d.price + "<br/>" + d.tweet)
         .style("left", (d3.event.pageX + 40) + "px")
         .style("top", (d3.event.pageY - 28) + "px")
         .style("background", function() {
           if (d.sent == "good") {
             console.log("good");
             return "#77efab";
           }
           else if (d.sent == "bad") {
             console.log("bad");
             return "#e07967";
           }
         })
         .style("width", 120 + "px")
         .style("height", 180 +"px");
      })
    .on("mouseout", function(d) {
      d3.select(this).attr("height", 20).attr("width", 20)
      d3.selectAll(".line")
        .classed("line--hover", false)
        .classed("line--fade", false);
      svg.selectAll("image")
        .classed("image--fade", false)
        .classed("line--hover", false);
       div.transition()
         .duration(500)
         .style("opacity", 0);
       });

       svg.selectAll("image")
       .on('click', function(d) {
         var radarChartOptions = {
                 w: 300,
                 h: 300,
                 margin: {top: 40, right: 40, bottom: 40, left: 50},
                 legendPosition: {x: 20, y: 20},
                 maxValue: 1,
                 wrapWidth: 60,
                 levels: 4,
                 roundStrokes: true,
                 color: d3.scale.category10(),
                 axisName: "reason",
                 areaName: "device",
                 value: "value"
           };
           d3.json("data123.json", function(error, data){
             console.log("data",data);
             // console.log("singledata",data[key]);
             var singledata = new Array();
             var name;
             for (var i = 0; i < data.length; i ++){
               console.log("dataof[i]",data[i]);
               console.log("d",d);
               if (d.symbol == data[i].key){
                 name = data[i].values[0].name;
                 singledata.push(data[i]);
               }
             }
             RadarChart("#radar2", singledata, radarChartOptions);
           });
       })
  values.enter().append("path")
    .attr("class", "line")
    .on("mouseover", function(d){
      var me = this;
      var mouse = d3.mouse(this);
      var currentValue = new Array();
      var val,date,key,datavalue;
      var lines = document.getElementsByClassName('line');
      d3.selectAll(".mouse-per-line")
        .attr("transform", function(d, i) {
          var xDate = x.invert(mouse[0]),
              bisect = d3.bisector(function(d) {
                date = d.date
                return d.date; }).right;
              idx = bisect(d.values, xDate);
          var beginning = 0,
              end = lines[i].getTotalLength(),
              target = null;

          while (true){
            target = Math.floor((beginning + end) / 2);
            pos = lines[i].getPointAtLength(target);
            if ((target === end || target === beginning) && pos.x !== mouse[0]) {
                break;
            }
            if (pos.x > mouse[0]){
              end = target;
            }
            else if (pos.x < mouse[0]) {
              beginning = target;
            }
            else break; //position found
          }
          currentValue.push({id: d.key, date: d.date, yval: y.invert(pos.y).toFixed(2)});
        });
      //find data on point hovered over
      data.forEach(function(element) {
        for (var i = 0; i < currentValue.length; i++) {
          if ((currentValue[i].yval <= element.price+1) && (currentValue[i].yval >= element.price-1) && (currentValue[i].id == d.key) && (currentValue[i].date == date)) {
            // key = currentValue[i].key;
            val = element.price;

          }
          else if ((val == undefined) && (currentValue[i].yval <= element.price+2) && (currentValue[i].yval >= element.price-2) && (currentValue[i].id == d.key)){
            val = element.price;
          }
        }

      })
      //append to tooltip
      div.transition()
        .duration(200)
        .style("opacity", .9);
      date = date.toString().split(" ");
      date = date[1] + " " + date[2] + " " + date[3];
      console.log("date",date);
      div.html(date + "<br/>" + d.key + "<br/>" + val)
        .style("left", (d3.event.pageX) + "px")
        .style("top", (d3.event.pageY - 28) + "px")
        .style("background", "lightsteelblue")
        .style("width", 80 + "px")
        .style("height", 45 +"px");
      d3.select(d.line).classed("line--hover", true);
      d3.selectAll("image").classed("image--fade",true);
      d3.selectAll(".line").classed("line--hover", function() {
        return (this === me);
      }).classed("line--fade", function() {
        return (this !== me);
      });
    })
    .on('click', function(d) {
      console.log("click",d);
      var radarChartOptions = {
              w: 300,
              h: 300,
              margin: {top: 40, right: 40, bottom: 40, left: 50},
              legendPosition: {x: 20, y: 20},
              maxValue: 1,
              wrapWidth: 60,
              levels: 4,
              roundStrokes: true,
              color: d3.scale.category10(),
              axisName: "reason",
              areaName: "device",
              value: "value"
        };
        d3.json("data123.json", function(error, data){
          // console.log("singledata",data[key]);
          var singledata = new Array();
          var name;
          for (var i = 0; i < data.length; i ++){
            console.log("dataof[i]",data[i]);
            if (d.key == data[i].key){
              name = data[i].values[0].name;
              singledata.push(data[i]);
            }
          }

          RadarChart("#radar2", singledata, radarChartOptions);
        });
    })
    .on("mouseout", function() {
      d3.selectAll("image").classed("image--fade",false);
      d3.selectAll(".text-display")
        .style("opacity", 0);
      d3.selectAll(".line")
        .classed("line--hover", false)
        .classed("line--fade", false);
      div.transition()
        .duration(500)
        .style("opacity", 0);
    })
    .on('mousemove', function() { // mouse moving over canvas
      var mouse = d3.mouse(this);
      d3.select(".mouse-line")
        .attr("d", function() {
          var d = "M" + mouse[0] + "," + height;
          d += " " + mouse[0] + "," + 0;
          return d;
        })
    })

};


function clearAll(){
  d3.selectAll(".line", ".dot", "image", ".circle")
	.transition().duration(100)
			.attr("d", function(d){
        return null;
      });
   svg.selectAll("image").style("visibility","hidden");

};



function showAll(){
  d3.selectAll(".line", ".dot", "image", ".circle")
	.transition().duration(100)
			.attr("d", function(d){
        if ((d!="sentiment") && (d!="day") && (d!="week") && (d!="month")){
          return priceline(d.values);
        }
      });
  svg.selectAll("image").style("visibility","visible");

};
