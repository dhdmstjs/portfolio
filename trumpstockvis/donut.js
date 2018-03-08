function donutChart() {
    var width,
        height,
        margin = {top: 1000, right: 10, bottom: 10, left: 10},
        colour = d3.scale.category20(), // colour scheme
        variable, // value in data that will dictate proportions on chart
        category, // compare data by
        padAngle, // effectively dictates the gap between slices
        floatFormat = d3.format('.4r'),
        cornerRadius, // sets how rounded the corners are on each slice
        percentFormat = d3.format(',.2%');


    function chart(selection){
        selection.each(function(data) {
            // generate chart
            // Set up constructors for making donut
            var radius = Math.min(width, height) / 2;
            var filteredData = new Array();
            var vals = new Array();
            var names = new Array();
            /// add names of companies
            var tech = new Array();
            var comm = new Array();
            var auto = new Array();
            var retail = new Array();
            var finance = new Array();
            var pub = new Array();
            var manu = new Array();
            var aero = new Array();
            var Tech = 0, Communications = 0, Aerospace = 0, Automobile = 0, Finance = 0, Retail = 0, Publishing = 0, Manufacturing = 0;
            for (var j = 0; j < data.length; j++){
              var inds = data[j].values[0].inds;
              var test = new Array();
              if (inds == "Tech") {
                Tech ++;
                tech.push(data[j].values[0].name)
              } else if (inds == "Communications") {
                Communications++;
                comm.push(data[j].values[0].name)
              } else if (inds == "Aerospace") {
                Aerospace ++;
                aero.push(data[j].values[0].name)
              } else if (inds == "Automobile") {
                Automobile ++;
                auto.push(data[j].values[0].name)
              } else if (inds == "Finance") {
                Finance ++;
                finance.push(data[j].values[0].name)
              } else if (inds == "Retail") {
                Retail ++;
                retail.push(data[j].values[0].name)
              } else if (inds == "Publishing") {
                Publishing ++;
                pub.push(data[j].values[0].name)
              } else if (inds == "Manufacturing") {
                Manufacturing ++;
                manu.push(data[j].values[0].name)
              }
            }
            var newData = new Array();
            vals.push({Tech:Tech/19,Communications:Communications/19,Aerospace:Aerospace/19,Automobile:Automobile/19,Finance:Finance/19,Retail:Retail/19,Publishing:Publishing/19,Manufacturing: Manufacturing/19});
            var inds;
            for (var i = 0; i < data.length; i ++){
              var len = data.length;
              inds = data[i].values[0].inds
              filteredData.push({key:data[i].key,Industry:inds,Name: data[i].values[0].name, Percentage:vals[0][inds]})
            }
            newData.push({key:"Technology",values:tech,Percentage:vals[0].Tech});
            newData.push({key:"Communications",values:comm,Percentage:vals[0].Communications});
            newData.push({key:"Automobile",values:auto,Percentage:vals[0].Automobile});
            newData.push({key:"Retail",values:retail,Percentage:vals[0].Retail});
            newData.push({key:"Finance",values:finance,Percentage:vals[0].Finance});
            newData.push({key:"Publishing",values:pub,Percentage:vals[0].Publishing});
            newData.push({key:"Manufacturing",values:manu,Percentage:vals[0].Manufacturing});
            newData.push({key:"Aerospace",values:aero,Percentage:vals[0].Aerospace});



            data = newData

            // creates a new pie generator
            var pie = d3.layout.pie()
                .value(function(d) {
                  if (d[variable] != undefined){
                    return floatFormat(d[variable])}
                   ;})
                .sort(null);

            // contructs and arc generator. This will be used for the donut. The difference between outer and inner
            // radius will dictate the thickness of the donut
            var arc = d3.svg.arc()
                .outerRadius(radius * 0.8)
                .innerRadius(radius * 0.6)
                .cornerRadius(cornerRadius)
                .padAngle(padAngle);

            // this arc is used for aligning the text labels
            var outerArc = d3.svg.arc()
                .outerRadius(radius * 0.9)
                .innerRadius(radius * 0.9);

            // append the svg object to the selection
            var svg = selection.append('svg')
                .attr('width', width + margin.left + margin.right)
                .attr('height', height + margin.top + margin.bottom)
              .append('g')
                .attr('transform', 'translate(' + width / 2 + ',' + height / 2 + ')');

            // g elements to keep elements within svg modular
            svg.append('g').attr('class', 'slices');
            svg.append('g').attr('class', 'labelName');
            svg.append('g').attr('class', 'lines');

            // add and color the donut slices
            var path = svg.select('.slices')
                .datum(data).selectAll('path')
                .data(pie)
              .enter().append('path')
                .attr('fill', function(d) {
                  return color(d.data.key); })
                .attr('stroke', function(d) {
                  return color(d.data.key); })
                .attr('d', arc);

            // add text labels
            var label = svg.select('.labelName').selectAll('text')
                .data(pie(data))
                .enter().append('text')
                .style('font-size', '1.2em')
                .attr('dy', '.35em')
                .style ("stroke", "white")
                .html(function(d) {
                    // add "key: value" for given category. Number inside tspan is bolded in stylesheet.
                    return d.data.key + ': <tspan>' + percentFormat(d.data[variable]) + '</tspan>';
                })
                .attr('transform', function(d) {
                    // effectively computes the centre of the slice.
                    var pos = outerArc.centroid(d);
                    // changes the point to be on left or right depending on where label is.
                    pos[0] = radius * 0.95 * (midAngle(d) < Math.PI ? 1 : -1);
                    return 'translate(' + pos + ')';
                })
                .style('text-anchor', function(d) {
                    // if slice centre is on the left, anchor text to start, otherwise anchor to end
                    return (midAngle(d)) < Math.PI ? 'start' : 'end';
                });

            // add lines connecting labels to slice. A polyline creates straight lines connecting several points
            var polyline = svg.select('.lines')
                .selectAll('polyline')
                .data(pie(data))
              .enter().append('polyline')
                .attr('points', function(d) {
                    // label transform function
                    var pos = outerArc.centroid(d);
                    pos[0] = radius * 0.95 * (midAngle(d) < Math.PI ? 1 : -1);
                    return [arc.centroid(d), outerArc.centroid(d), pos]
                });

            // add tooltip to mouse events on slices and labels
            d3.selectAll('.labelName text, .slices path').call(toolTip);

            // Functions

            // calculates the angle for the middle of a slice
            function midAngle(d) {
              return d.startAngle + (d.endAngle - d.startAngle) / 2; }

            // function that creates and adds the tool tip to a selected element
            function toolTip(selection) {
                // add tooltip (svg circle element) when mouse enters label or slice
                selection.on('mouseenter', function (data) {
                  console.log("datamouse",data.data.values);
                  svg.append('circle')
                      .attr('class', 'toolCircle')
                      .attr('r', radius * 0.55) // radius of tooltip circle
                      .style('fill', color(data.data.key)) // color based on category mouse is over
                      .style('fill-opacity', 0.35);
                    svg.append('text')
                        .attr('class', 'toolCircle')
                        .attr('dy', -15) // hard-coded. can adjust this to adjust text vertical alignment in tooltip
                        .html(toolTipHTML(data)) // add text to the circle.
                        .style('font-size', '1.2em')
                        .style ("stroke", 'white')
                        .style("fill","white")
                        .style("white-space","initial")
                        .style("text-overflow","initial")
                        .style('text-anchor', 'middle'); // centres text in tooltip

                });
                // remove the tooltip when mouse leaves the slice/label
                selection.on('mouseout', function () {
                    d3.selectAll('.toolCircle').remove();
                });
            }

            // function to create the HTML string for the tool tip. Loops through each key in data object
            // and returns the html string key: value
            function toolTipHTML(data) {
                var tip = '',
                    i   = 0;
                for (var key in data.data) {
                    // if value is a number, format it as a percentage
                    var value = (!isNaN(parseFloat(data.data[key]))) ? percentFormat(data.data[key]) : data.data[key];
                    // leave off 'dy' attr for first tspan so the 'dy' attr on text element works. The 'dy' attr on
                    // tspan effectively imitates a line break.
                    if (i === 0) tip += '<tspan x="0">' + key + ': ' + value + '</tspan>';
                    else tip += '<tspan x="0" dy="1.2em">' + key + ': ' + value + '</tspan>';
                    i++;
                }
              return tip;
            }

        });
    }
    // getter and setter functions
    chart.width = function(value) {
        if (!arguments.length) return width;
        width = value;
        return chart;
    };

    chart.height = function(value) {
        if (!arguments.length) return height;
        height = value;
        return chart;
    };

    chart.margin = function(value) {
        if (!arguments.length) return margin;
        margin = value;
        return chart;
    };

    chart.radius = function(value) {
        if (!arguments.length) return radius;
        radius = value;
        return chart;
    };

    chart.padAngle = function(value) {
        if (!arguments.length) return padAngle;
        padAngle = value;
        return chart;
    };

    chart.cornerRadius = function(value) {
        if (!arguments.length) return cornerRadius;
        cornerRadius = value;
        return chart;
    };

    chart.color = function(value) {
        if (!arguments.length) return color;
        color = value;
        return chart;
    };

    chart.variable = function(value) {
        if (!arguments.length) return variable;
        variable = value;
        return chart;
    };

    chart.category = function(value) {
        if (!arguments.length) return category;
        category = value;
        return chart;
    };

    return chart;

}
