#!/usr/bin/env node

const showdown = require('showdown');
const fs = require('fs');
const path = require('path');
const diff = require('diff');
const converter = new showdown.Converter();
converter.setOption('tasklists', true);

const FILE_NAME = "readme.txt";
const HTML_FOOT = '</div><script src="../main.js"></script></body></html>';

let folder = process.argv[2];
if (folder == null) {
    folder = ".";
}

function isNumericName(value) {
    return /^\d+$/.test(value);
}

function fileExists(filePath) {
    if (fs.existsSync(filePath)) {
        return true;
    } else {
        console.error("File does not exist: " + filePath);
        return false;
    }
}

function htmlHead(title) {
    return `
    <!doctype html><html lang="en">
    <head>
        <meta charset="utf-8">
        <title>${title}</title>
        <link rel="stylesheet" href="../highlight.css">
        <link rel="stylesheet" href="../main.css">
        <script src="../highlight.pack.js"></script>
        <script>hljs.highlightAll();</script>
    </head>
    <body>
    <header>
        <div>
            <span>${title}</span>
            <a href="https://www.entigo.com/" target="_blank"><img src="../logo.svg" alt="entigo-logo"/></a>
        </div>
    </header>
    <div class="body">`;
}

function feedbackForm(labNr) {
    return `
    <h3>Feedback</h3>
    <form id="feedbackForm">
        <label for="lab_nr" style="display: none">Lab nr<span class="important">*</span></label>
        <input type="number" id="lab_nr" name="lab_nr" required value="${labNr}" style="display: none"/>
        <p>Please evaluate this lab on a scale of 1 to 5 stars, where 1 signifies the worst and 5 signifies excellence.</p>
        <div class="ratings">
            ${rating("Overall", "overall", 5)}
            ${rating("Clarity and comprehensibility", "difficulty", 5)}
            ${rating("Usefulness for me", "usefulness", 5)}
        </div>
        <label for="comment">Comment or recommendation</label><br />
        <textarea id="comment" name="comment" rows="4" cols="50"></textarea><br />
        <p id="error" class="important" style="display: none"></p>
        <p id="success" class="success" style="display: none">Thank you for your feedback!</p>
        <input type="submit" value="Submit" id="submit">
    </form>
    `;
}

function rating(title, name, limit) {
    let inputs = [];
    for (let i = 1; i <= limit; i++) {
        inputs.push(`<span class="star" data-value="${i}">&#9733;</span>`);
    }
    return `<label for="${name}">${title}<span class="important">*</span></label>
            <div class="star-rating" data-category="${name}">
                ${inputs.join("\n                ")}
            </div>
            <input type="hidden" name="${name}" id="${name}Rating" value="0">`;
}

function startCodeBlock(lang) {
    if (lang === "") {
        return "<pre><code>";
    } else {
        return `<pre><code class="${lang} language-${lang}">`;
    }
}

function endCodeBlock() {
    return "</code></pre>\n";
}

function labLink(folder, title) {
    const dashIndex = title.lastIndexOf("-");
    if (dashIndex !== -1) {
        title = title.substring(dashIndex + 1);
    }
    return `<li><a href="./${folder}/index.html">${title}</a></li>\n`;
}

function trimLeftByChar(string, character) {
    const first = [...string].findIndex(char => char !== character);
    return string.substring(first);
}

function replaceAll(str, find, replace) {
    return str.replace(new RegExp(find, 'g'), replace);
}

function getCourseTitle(labTitle) {
    const dashIndex = labTitle.lastIndexOf("-");
    if (dashIndex !== -1) {
        return labTitle.substring(0, dashIndex - 1) + " LABS";
    } else {
        return "Course Labs";
    }
}

function writeIndexPage(labs, htmlFolder) {
    if (Object.keys(labs).length > 0) {
        const title = getCourseTitle(labs[Object.keys(labs)[0]]);
        let html = `
        <!doctype html><html lang="en">
        <head>
            <meta charset="utf-8">
            <title>${title}</title>
            <link rel="stylesheet" href="./main.css">
        </head>
        <body>
        <header>
            <div>
                <span>${title}</span>
                <a href="https://www.entigo.com/" target="_blank"><img src="./logo.svg" alt="entigo-logo"/></a>
            </div>
        </header>
        <div class="body">
        <ul class="labs-list">
        `;

        for (const key in labs) {
            html += labLink(key, labs[key]);
        }

        html += "</ul></body></html>";
        fs.writeFile(path.join(htmlFolder, ("index.html")), html, function (err) {
            if (err) {
                console.error("Could not write main index file", err);
                process.exit(1);
            }

            console.log("Main index written to " + htmlFolder);
        });
    }
}

function processReadMeFile(dirent, readMePath, readMeFile) {
    const file = {};
    file.content = "";
    file.title = "Lab " + dirent.name;

    let firstLine = true;
    const fileContent = fs.readFileSync(readMeFile, "utf8");
    const lines = fileContent.split(/\r?\n/);
    while (lines.length > 0) {
        const line = lines.shift();
        if (firstLine) {
            if (line.startsWith('#')) {
                file.title = trimLeftByChar(line, '#');
            }
            firstLine = false;
            continue;
        }
        if (line.startsWith('>') || line.startsWith('<')) {
            file.content += processCodeBlock(line, lines, readMePath, dirent.name);
        } else {
            file.content += line + "\n";
        }
    }
    return file;
}

function processCodeBlock(line, lines, readMePath, direntName) {
    const blocks = [];
    let block = {};
    while (true) {
        let isCode = true;
        const closed = line.startsWith('<');
        line = line.substring(2).trimEnd();
        const parts = line.split(" ");
        if (parts[1] === "cat" && parts.length < 4) {
            const fileName = getCatFileName(parts[2], direntName);
            const filePath = path.join(readMePath, fileName);
            if (fileExists(filePath)) {
                if (Object.keys(block).length > 0) {
                    blocks.push(block);
                    block = {};
                }
                blocks.push(customBlock(catFile(filePath, parts[2])));
                isCode = false;
            }
        } else if (parts[1] === "diff") {
            if (parts.length < 4) {
                console.error("Diff command must include 2 files");
                process.exit(1);
            }
            const firstFile = getCatFileName(parts[2], direntName);
            const firstFilePath = path.join(readMePath, firstFile);
            const secondFile = getCatFileName(parts[3], direntName);
            const secondFilePath = path.join(readMePath, secondFile);
            if (fileExists(firstFilePath) && fileExists(secondFilePath)) {
                if (Object.keys(block).length > 0) {
                    blocks.push(block);
                    block = {};
                }
                blocks.push(customBlock(diffFile(firstFilePath, parts[2], secondFilePath, parts[3])));
                isCode = false;
            }
        }
        if (isCode) {
            if (closed) {
                if (Object.keys(block).length > 0) {
                    blocks.push(block);
                    block = {};
                }
                blocks.push(customBlock(`\n<details class="cmd-one-line"><summary>Show command</summary>${startCodeBlock("shell")}${line}\n${endCodeBlock()}</details>\n\n`.toString()));
            } else {
                if (Object.keys(block).length === 0) {
                    block.addCodeBlock = true;
                    block.content = "";
                    block.language = getCodeBlockLanguage(line);
                }
                block.content += line + "\n";
            }
        }
        line = lines.shift();
        if (!line || (!line.startsWith('>') && !line.startsWith('<'))) {
            lines.unshift(line);
            break;
        }
    }
    if (Object.keys(block).length > 0) {
        blocks.push(block);
    }

    return createCodeBlocks(blocks);
}

function getCatFileName(fileName, direntName) {
    if (fileName.startsWith('~')) {
        fileName = fileName.replace("~/", '');
        if (fileName.startsWith(direntName)) {
            fileName = fileName.replace(direntName + "/", '');
        } else {
            fileName = "../" + fileName;
        }
    }
    return fileName;
}

function catFile(filePath, fileName) {
    const file = fs.readFileSync(filePath, "utf8");
    let highlightType = "yaml";
    if (fileName.toLocaleLowerCase().endsWith("dockerfile")) {
        highlightType = "dockerfile";
    } else {
        const extensionIndex = fileName.lastIndexOf(".");
        if (extensionIndex !== -1) {
            const fileExtension = fileName.substring(extensionIndex + 1).toLocaleLowerCase();
            if (fileExtension === "repo" || fileExtension === "conf") {
                highlightType = "properties";
            } else {
                highlightType = fileExtension;
            }
        }
    }
    const fileDisplayName = fileName.replace(/_/g, "\\_").replace(/-/g, "\\-");
    const fileTemplate = `\n<details class="cmd-file"><summary>Show ${fileDisplayName} <span class="show-text">&plus;</span></summary>${startCodeBlock(highlightType)}${file}\n${endCodeBlock()}</details>\n\n`;
    return fileTemplate.toString();
}

function diffFile(firstFilePath, firstFile, secondFilePath, secondFile) {
    const firstFileContent = fs.readFileSync(firstFilePath, "utf8");
    const secondFileContent = fs.readFileSync(secondFilePath, "utf8");
    const ignoreWhitespace = false;
    const filesDiff = diff.diffLines(firstFileContent, secondFileContent, ignoreWhitespace);
    let diffContent = "";
    let lastPrefix;
    filesDiff.forEach((part) => {
        let prefix = " ";
        if (part.added) {
            prefix = "+";
            if (lastPrefix === " ") {
                diffContent = diffContent.replace(/ \n$/, "");
            }
        } else if (part.removed) {
            prefix = "-";
            if (lastPrefix === " ") {
                diffContent = diffContent.replace(/ \n$/, "");
            }
        }
        part.value.split(/\r?\n/).forEach((line) => {
            diffContent += prefix + line + "\n";
        });
        if (prefix === "+" || prefix === "-") {
            diffContent = diffContent.replace(/[+-]\n$/, "");
        }
        lastPrefix = prefix;
    });
    const firstFileDisplayName = firstFile.replace(/_/g, "\\_").replace(/-/g, "\\-");
    const secondFileDisplayName = secondFile.replace(/_/g, "\\_").replace(/-/g, "\\-");
    const template = `\n<details class="cmd-file"><summary>Show diff ${firstFileDisplayName} ${secondFileDisplayName} <span class="show-text">&plus;</span></summary>${startCodeBlock("diff")}${diffContent}\n${endCodeBlock()}</details>\n\n`;
    return template.toString();
}

function customBlock(content) {
    const block = {};
    block.addCodeBlock = false;
    block.content = content;
    return block;
}

function getCodeBlockLanguage(line) {
    let language = "shell";
    if (line.startsWith("mysql>")) {
        language = "sql";
    } else if (!(line.startsWith("$") || line.startsWith("#"))) {
        language = "";
    }
    return language;
}

function createCodeBlocks(blocks) {
    let codeBlocks = "";
    for (let block of blocks) {
        if (block) {
            if (block.addCodeBlock) {
                codeBlocks += startCodeBlock(block.language);
                codeBlocks += block.content;
                codeBlocks += endCodeBlock();
            } else {
                codeBlocks += block.content;
            }
        }
    }
    return codeBlocks;
}

function writeReadMeFile(file, direntName, htmlFolder) {
    const html = htmlHead(file.title) + converter.makeHtml(file.content) + feedbackForm(direntName) + HTML_FOOT;
    const htmlPath = path.join(htmlFolder, direntName);
    if (!fs.existsSync(htmlPath)) {
        fs.mkdirSync(htmlPath);
    }
    fs.writeFile(path.join(htmlPath, ("index.html")), html, function (err) {
        if (err) {
            console.error("Could not write an html file", err);
            process.exit(1);
        }

        console.log("Readme html written to " + htmlPath);
    });
}

fs.readdir(folder, { withFileTypes: true }, function (err, files) {
    if (err) {
        console.error("Could not list the directory.", err);
        process.exit(1);
    }

    const htmlFolder = path.join(folder, "html");
    if (!fs.existsSync(htmlFolder)) {
        fs.mkdirSync(htmlFolder);
    }

    const labs = {};
    files.forEach(function (dirent) {
        if (dirent.isDirectory() && isNumericName(dirent.name)) {
            fs.readdirSync(folder, function (err) {
                if (err) {
                    console.error("Could not list the directory.", err);
                    process.exit(1);
                }
            });

            const readMePath = path.join(folder, dirent.name);
            const readMeFile = path.join(readMePath, FILE_NAME);

            if (fileExists(readMeFile)) {
                const file = processReadMeFile(dirent, readMePath, readMeFile);
                if (file.content !== "") {
                    writeReadMeFile(file, dirent.name, htmlFolder);
                    labs[dirent.name] = file.title;
                }
            }
        }
    });
    writeIndexPage(labs, htmlFolder);
});
