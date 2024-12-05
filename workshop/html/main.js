const urlParams = new URLSearchParams(window.location.search);
const userNr = urlParams.get('user') !== null ? urlParams.get('user').replace(/[^0-9]/g, '') : null;
if (!userNr) {
    promptForUserNr();
}

function promptForUserNr() {
    let input = prompt("Please enter your user number:");
    if (isNaN(input)) {
        alert("Invalid input. Please enter a number.");
    }
    let url = new URL(window.location.href);
    url.searchParams.set('user', input);
    window.location.href = url.toString();
}

const hiddenCommands = document.querySelectorAll(".cmd-one-line");
const checkBoxes = document.querySelectorAll("input[type=checkbox]");

function replaceCommand(command) {
    const preChild = command.querySelector("pre");
    command.parentNode.replaceChild(preChild, command);
    preChild.style.display = "block";
}

String.prototype.replaceAll = function(search, replacement) {
    const target = this;
    return target.replace(new RegExp(search, 'gm'), replacement);
};

hiddenCommands.forEach((command) => {
    command.querySelector("pre").style.display = "none";
    command.addEventListener("click", () => replaceCommand(command));
});

if (userNr !== null && userNr !== '') {
    const allCodes = document.querySelectorAll("code");
    allCodes.forEach((code) => {
        code.innerHTML = code.innerHTML.replaceAll("userN", "user" + userNr).replaceAll("uN", "u" + userNr).replaceAll("docker-N", "docker-" + userNr)
            .replaceAll("KubeLabN", "KubeLab" + userNr).replaceAll("devops-N", "devops-" + userNr).replaceAll("infralib-N", "infralib-" + userNr);
    });

    const links = document.querySelectorAll("a");
    links.forEach((link) => {
        link.innerHTML = link.innerHTML.replaceAll("userN", "user" + userNr).replaceAll("uN", "u" + userNr).replaceAll("docker-N", "docker-" + userNr)
            .replaceAll("KubeLabN", "KubeLab" + userNr).replaceAll("devops-N", "devops-" + userNr).replaceAll("infralib-N", "infralib-" + userNr);
        link.href = link.innerHTML;
    });
}

const allFiles = document.querySelectorAll(".cmd-file");

function showFile(file) {
    const preChild = file.parentNode.querySelector("pre");
    if (preChild.style.display === "none") {
        file.querySelector(".show-text").innerHTML = '&minus;';
        preChild.style.display = 'block'
    } else {
        file.querySelector(".show-text").innerHTML = '&plus;';
        preChild.style.display = 'none'
    }
}

allFiles.forEach((file) => {
    file.querySelector("pre").style.display = "none";
    const summaries = file.querySelectorAll("summary");
    summaries.forEach((summary) => summary.addEventListener("click", () => showFile(summary)));
});

function revealAnswer(checkbox) {
    if (checkbox.checked) {
        if (checkbox.classList.contains("correct")) {
            checkbox.parentNode.classList.add("show-correct");
            const list = checkbox.parentNode.parentNode;
            const uncheckedCorrectAnswers = list.querySelectorAll("input[type=checkbox].correct:not(:checked)");
            if (uncheckedCorrectAnswers.length === 0) {
                const siblingAnswers = list.querySelectorAll("input[type=checkbox]");
                siblingAnswers.forEach((siblingAnswer) => siblingAnswer.disabled = true);
            }
        } else {
            checkbox.parentNode.classList.add("show-false");
        }
    } else {
        if (checkbox.classList.contains("correct")) {
            checkbox.parentNode.classList.remove("show-correct");
        } else {
            checkbox.parentNode.classList.remove("show-false");
        }
    }
}

checkBoxes.forEach((checkbox) => {
    if (checkbox.checked) {
        checkbox.classList.add("correct");
        checkbox.checked = false;
    }
    checkbox.disabled = false;
    checkbox.addEventListener("click", () => revealAnswer(checkbox));
});

const copyButtonLabel = "&#10697;";
const blocks = document.querySelectorAll("pre");

if (navigator.clipboard) {
    blocks.forEach((block) => {
        if (block.querySelectorAll("code").length === 0) {
            return;
        }
        let button = document.createElement("button");
        button.classList.add("copy-button");
        button.innerHTML = copyButtonLabel;
        block.appendChild(button);
        button.addEventListener("click", async () => {
            await copyCode(block, button);
        });
    });
}

async function copyCode(block, button) {
    const code = block.querySelector("code");
    let text = code.innerText.replaceAll(/^(\$+|#+)\s+/, '');
    if (text.slice(-1) === "\n") {
        text = text.slice(0, -1);
    }

    await navigator.clipboard.writeText(text);

    button.innerHTML = "&#10003;";
    setTimeout(() => {
        button.innerHTML = copyButtonLabel;
    }, 1000);
}

function getStudentId() {
    // Not secure, but good enough for this use-case
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
        let r = Math.random() * 16 | 0,
            v = c === 'x' ? r : (r & 0x3 | 0x8);
        return v.toString(16);
    });
}
const studentId = getStudentId();

const categories = ['overall', 'difficulty', 'usefulness'];
const selectedRatings = {
    overall: 0,
    difficulty: 0,
    usefulness: 0
};

categories.forEach(category => {
    const stars = document.querySelectorAll(`.star-rating[data-category="${category}"] .star`);
    const hiddenInput = document.getElementById(`${category}Rating`);

    stars.forEach(star => {
        star.addEventListener('click', () => {
            const value = star.getAttribute('data-value');
            selectedRatings[category] = value;
            hiddenInput.value = value;
            highlightStars(category, value);
        });

        star.addEventListener('mouseover', () => {
            const value = star.getAttribute('data-value');
            highlightStars(category, value);
        });

        star.addEventListener('mouseout', () => {
            highlightStars(category, selectedRatings[category]); // Reset to the selected rating
        });
    });
});

function highlightStars(category, value) {
    const stars = document.querySelectorAll(`.star-rating[data-category="${category}"] .star`);
    stars.forEach(star => {
        if (star.getAttribute('data-value') <= value) {
            star.classList.add('selected');
        } else {
            star.classList.remove('selected');
        }
    });
}

document.getElementById('feedbackForm').addEventListener('submit', function (event) {
    event.preventDefault();
    document.getElementById('submit').disabled = true;
    document.getElementById('success').style.display = 'none';
    document.getElementById('error').style.display = 'none';

    let formData = {};
    for (let element of event.target.elements) {
        if (element.name) {
            if (element.type === 'number') {
                formData[element.name] = parseInt(element.value);
            } else if (element.type === 'hidden') {
                formData[element.name] = parseInt(element.value);
            } else if (element.type === 'textarea') {
                formData[element.name] = element.value;
            }
        }
    }
    formData['student_id'] = studentId;

    fetch('/submit', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(formData),
    })
        .then(response => {
            if (response.ok) {
                document.getElementById('success').style.display = 'block';
                return {};
            } else if (!!response.body && response.headers.get('Content-Type')?.includes('application/json')) {
                document.getElementById('submit').disabled = false;
                return response.json();
            }
            return {error: 'Request failed with status code ' + response.status + ' ' + response.statusText};
        }).then(data => {
        if (data.error) {
            document.getElementById('error').textContent = data.error;
            document.getElementById('error').style.display = 'block';
        }
    })
        .catch((error) => {
            console.error('Error:', error);
            document.getElementById('error').textContent = error;
            document.getElementById('error').style.display = 'block';
            document.getElementById('submit').disabled = false;
        });
});
