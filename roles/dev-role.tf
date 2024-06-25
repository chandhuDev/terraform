data "aws_caller_identity" "current" {}

resource "aws_iam_role" "dev-role" {
  name               = "staging-role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${var.dev-role}"
      }
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "dev-role-policy" {
  name   = "staging-role-policy"
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "eks:*"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:PassedToService": "eks.amazonaws.com"
                }
            }
        }
    ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "dev-role-attachment" {
  policy_arn = aws_iam_policy.dev-role-policy.arn
  role = aws_iam_role.dev-role.arn
}


resource "aws_iam_user" "stag-dev-user" {
  name = "stag-dev-user"
}

resource "aws_iam_policy" "stag-dev-user-policy" {
  name = "AmazonEKSDevPolicy"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sts:AssumeRole"
            ],
            "Resource": "${aws_iam_role.dev-role.arn}"
        }
    ]
}
POLICY
}

resource "aws_iam_user_policy_attachment" "stag-dev-role-attachment" {
  user = aws_iam_user.prod-test-user.arn
  policy_arn = aws_iam_policy.test-role-policy.arn
}

resource "aws_eks_access_entry" "stag-dev-acess-entry" {
  cluster_name      = var.eks-name
  principal_arn     = aws_iam_role.test-role.arn
  kubernetes_groups = ["devGroup"]
}
